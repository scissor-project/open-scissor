#!/bin/bash -ex

umask 022

cat > /tmp/scissor-log.sh << EOF
LOG="/var/log/kafka.log"

function log() {
    msg="$(date --iso-8601=ns) \"\$1\""
    echo "\$msg" >> \$LOG
}
EOF

# shellcheck disable=SC1091
source /tmp/scissor-log.sh
rm -f "$LOG"


cd /etc/zookeeper/conf
git init .
git remote add -t \* -f origin https://anc-git.salzburgresearch.at/gkatzinger/zookeeperd-config.git
git checkout -f master
log "Cloned zookeeperd-config"

service zookeeper restart
log "Restarted zookeeper"

cd /opt
mkdir kafka
cd kafka
wget "http://www.eu.apache.org/dist/kafka/0.8.2.2/kafka_2.10-0.8.2.2.tgz"
tar -xvzf kafka_2.10-0.8.2.2.tgz --strip 1
log "Downloaded and extracted kafka"

cd /opt
mkdir zookeeper-lib
cd zookeeper-lib
git clone -b master https://anc-git.salzburgresearch.at/ppaiva/zookeeper-lib.git .
log "Cloned zookeeper-lib"

cd /opt
mkdir zookeeper-master
cd zookeeper-master
git clone -b master https://anc-git.salzburgresearch.at/ppaiva/zookeeper-master.git .
log "Cloned zookeeper-master"
