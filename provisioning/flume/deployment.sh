#!/bin/bash -ex

umask 022

# shellcheck disable=SC1091
source /tmp/scissor-log.sh

FLUME_IP="$1"
NODE_NAME="$2"
KAFKA_IP="$3"
SEMANTICS_IP="$4"

hostnamectl set-hostname "$NODE_NAME"

# add new hostname to /etc/hosts
sed -i "/^127\\.0\\.0\\.1/ s/\$/ $NODE_NAME/" /etc/hosts

sed -i "s/avro_host = 10\\.0\\.1\\.12/avro_host = $SEMANTICS_IP/g" /opt/flume-config/conf/ingest/ingest.conf
sed -i "s/avro_port = 10000/avro_port = 20000/g" /opt/flume-config/conf/ingest/ingest.conf
sed -i "s/10\\.0\\.1\\.12/$FLUME_IP/g" /opt/flume-config/conf/ingest/ingest.conf
sed -i "s/10\\.0\\.1\\.12/$FLUME_IP/g" /opt/flume-config/conf/ingest/flume-env.sh

sed -i "s/avro_host = 10\\.0\\.1\\.12/avro_host = $SEMANTICS_IP/g" /opt/flume-config/conf/filter/filter.conf
sed -i "s/avro_port = 20000/avro_port = 30000/g" /opt/flume-config/conf/filter/filter.conf
sed -i "s/10\\.0\\.1\\.12/$FLUME_IP/g" /opt/flume-config/conf/filter/filter.conf

sed -i "s/10\\.0\\.1\\.12/$FLUME_IP/g" /opt/flume-config/conf/output/output.conf
sed -i "s/10\\.0\\.1\\.100/$KAFKA_IP/g" /opt/flume-config/conf/output/output.conf

sed -i "s/172\\.16\\.96\\.104:2131/$KAFKA_IP:2181/g" /opt/zookeeper-agent/conf/agent.properties


cd /opt/flume-config
chmod u+x bin/*.sh
./bin/kill-and-start-flume-agents.sh
log "Started flume agents"

cd /opt
git clone https://anc-git.salzburgresearch.at/cbrand/linux-config.git
/opt/linux-config/deploy/deploy.sh
/opt/linux-config/deploy/deploy-scissor.sh
log "Deployed linux-config"

cd ../zookeeper-agent
chmod u+x bin/*.sh
./bin/runAgent.sh start

git config --global color.ui auto

log "Host $NODE_NAME ready on ${FLUME_IP} (attached to kafka on ${KAFKA_IP})"
