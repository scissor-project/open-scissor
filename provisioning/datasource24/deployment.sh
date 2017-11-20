#!/bin/bash -ex

umask 022

# shellcheck disable=SC1091
source /tmp/scissor-log.sh

NODE_NAME="$2"
LOGSTASH24_IP="$3"
LOGSTASH_IP="$4"
KAFKA_IP="$5"

hostnamectl set-hostname "$NODE_NAME"
# add new hostname to /etc/hosts
sed -i "/^127\\.0\\.0\\.1/ s/\$/$NODE_NAME/" /etc/hosts

cd /opt/zmq-bash-push
sed -i "s/10\\.0\\.1\\.10/$LOGSTASH_IP/g" play_camfile.sh
sed -i "s/10\\.0\\.1\\.10/$LOGSTASH_IP/g" play_envfile.sh
sed -i "s/10\\.0\\.1\\.10/$LOGSTASH_IP/g" play_netfile.sh
sed -i "s/10\\.0\\.1\\.10/$LOGSTASH_IP/g" favignana-nxlog.conf
sed -i "s/10\\.0\\.1\\.10/$LOGSTASH_IP/g" play_camfile_loop.sh
sed -i "s/10\\.0\\.1\\.10/$LOGSTASH_IP/g" play_envfile_loop.sh
sed -i "s/10\\.0\\.1\\.10$/$LOGSTASH_IP/g" test/run-test.sh
sed -i "s/10\\.0\\.1\\.100$/$KAFKA_IP/g" test/run-test.sh

cd /opt
git clone https://anc-git.salzburgresearch.at/cbrand/linux-config.git
/opt/linux-config/deploy/deploy.sh
/opt/linux-config/deploy/deploy-scissor.sh
log "Deployed linux config."

cd /etc/filebeat
rm -f ./*
git init
git remote add origin https://anc-git.salzburgresearch.at/scissor/beats-ds.git
git fetch
git checkout -t origin/logstash24

sed -i "s/10\\.0\\.1\\.16/$LOGSTASH24_IP/g" filebeat.yml

cd /root
mkdir pd
cd pd
mkdir beats

password="$(pwgen 13 1)"
echo "root:$password" | chpasswd

log "Waiting for logstash to copy certificate files"
#logstash24_copied=`ss-get --timeout 3600 LOGSTASH24.COPIED`

log "logstash has copied certificates now starting filebeat"
/etc/init.d/filebeat start

git config --global color.ui auto

log "Host $NODE_NAME ready (attached to logstash on ${LOGSTASH_IP} and ${LOGSTASH24_IP})."
