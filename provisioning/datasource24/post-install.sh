#!/bin/bash -x

umask 022

cat > /tmp/scissor-log.sh << EOF
LOG="/var/log/datasource.log"

function log() {
    msg="\`date --iso-8601=ns\` \$1"
    echo "\$msg" >> \$LOG
}
EOF

source /tmp/scissor-log.sh
rm -f $LOG

mkdir /opt/zmq-bash-push
cd /opt/zmq-bash-push
git clone -b logstash24 https://anc-git.salzburgresearch.at/gkatzinger/zeromq-tools.git .
log "Cloned zeromq-tools"

wget http://nxlog.org/system/files/products/files/1/nxlog-ce-2.9.1716-1_rhel7.x86_64.rpm
rpm -ivh nxlog-ce-2.9.1716-1_rhel7.x86_64.rpm
log "Installed nxlog"

mkdir -p /opt/kafka
cd /opt/kafka
wget "http://www.eu.apache.org/dist/kafka/0.8.2.2/kafka_2.10-0.8.2.2.tgz"
tar -xvzf kafka_2.10-0.8.2.2.tgz --strip 1
log "Downloaded and extracted kafka"

curl -L -O https://download.elastic.co/beats/filebeat/filebeat-1.3.1-x86_64.rpm
rpm -vi filebeat-1.3.1-x86_64.rpm

cd /etc/filebeat/
