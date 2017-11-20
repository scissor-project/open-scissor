#!/bin/bash -x

umask 022

source /tmp/scissor-log.sh

KAFKA_IP="$1"
NODE_NAME="$2"

hostnamectl set-hostname $NODE_NAME

# replace default 'ubuntu' name with our new hostname in /etc/hosts
sed -i "/127\.0\.1\.1/ s/ubuntu\$/$NODE_NAME/" /etc/hosts

sed -i "s/#advertised\.host\.name=.*/advertised.host.name=${KAFKA_IP}/g" /opt/kafka/config/server.properties
sed -i "s/log\.retention\.hours=168/log.retention.hours=4/g" /opt/kafka/config/server.properties
sed -i "s/172\.16\.96\.104:2131/$KAFKA_IP:2181/g" /opt/zookeeper-master/conf/master.properties

cd /opt
git clone https://anc-git.salzburgresearch.at/scissor/kafka-config.git
cp /opt/kafka-config/log4j.properties /opt/kafka/config/
log "Deployed kafka logging config"

cd /opt/kafka
./bin/kafka-server-start.sh config/server.properties &
echo $! > kafka.pid
log "Started kafka"

sleep 10

./bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic env --partitions 1 --replication-factor 1
./bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic cam --partitions 1 --replication-factor 1
./bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic scada --partitions 1 --replication-factor 1
./bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic net --partitions 1 --replication-factor 1
log "Created kafka topics env,cam,scada,net"

cd /opt
git clone https://anc-git.salzburgresearch.at/cbrand/linux-config.git
/opt/linux-config/deploy/deploy.sh
/opt/linux-config/deploy/deploy-scissor.sh
log "Deployed linux-config"

cd /opt/zookeeper-master
chmod u+x bin/*.sh
./bin/runMaster.sh start
log "Started zookeeper-master"

log "Host $NODE_NAME ready on ${KAFKA_IP}"

iptables -A INPUT -i ens3 -p tcp ! -s 78.104.175.149 --dport 22 -j LOG --log-prefix "SSH A: "
iptables -A INPUT -i ens3 -p tcp  -s 10.10.1.0/24 --dport 22 -j ACCEPT
iptables -A INPUT -i ens3 -p tcp  -s 10.10.1.152 --dport 22 -j ACCEPT
iptables -A INPUT -i ens3 -p tcp ! -s 78.104.175.149 --dport 22 -j DROP
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
sed -i '$ i\iptables-restore /etc/iptables/rules.v4' /etc/rc.local
