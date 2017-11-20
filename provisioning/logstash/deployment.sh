#!/bin/bash -ex

umask 022

# shellcheck disable=SC1091
source /tmp/scissor-log.sh

NODE_NAME="$2"
FLUME_IP="$3"
DATASOURCE24_IP="$4"
STREAMON_IP="$5"
CAMERA_IP="10.10.1.100"

hostnamectl set-hostname "$NODE_NAME"
# replace default 'ubuntu' name with our new hostname in /etc/hosts
sed -i "/127\\.0\\.1\\.1/ s/ubuntu\$/$NODE_NAME/" /etc/hosts

cd /etc/logstash/conf.d
git clone -b master https://anc-git.salzburgresearch.at/gkatzinger/logstash-config.git .
log "Cloned logstash-config"

sed -i "s/10\\.0\\.1\\.12/$FLUME_IP/g" /etc/logstash/conf.d/syslogng.conf
sed -i "s/10\\.0\\.1\\.9/$STREAMON_IP/g" /etc/logstash/conf.d/syslogng.conf
sed -i "s/10\\.0\\.1\\.200/$CAMERA_IP/g" /etc/logstash/conf.d/syslogng.conf
sed -i "s/10\\.0\\.1\\.11/$DATASOURCE24_IP/g" /etc/logstash/conf.d/syslogng.conf

systemctl restart logstash.service
systemctl enable logstash.service
log "Started logstash"

cd /opt
git clone https://anc-git.salzburgresearch.at/cbrand/linux-config.git
/opt/linux-config/deploy/deploy.sh
/opt/linux-config/deploy/deploy-scissor.sh
log "Deployed linux-config"

#Ensure that output files from logstash do not fill disk
echo "/tmp/logstash_output.txt {
        size 20M
        copytruncate
        rotate 4
}
" >> /etc/logrotate.conf
#Ensure that check for filesize is running each hour
cp /etc/cron.daily/logrotate /etc/cron.hourly

log "Host $NODE_NAME ready (attached to flume on ${FLUME_IP})"
