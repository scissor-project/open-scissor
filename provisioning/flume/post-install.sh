#!/bin/bash -x
cd /etc
echo "[cloudera-cdh5]
# Packages for Cloudera's Distribution for Hadoop, Version 5, on RedHat	or CentOS 6 x86_64
name=Cloudera's Distribution for Hadoop, Version 5
baseurl=https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5.5.2/
gpgkey =https://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera
gpgcheck = 1" > /etc/yum.repos.d/cloudera-cdh5.repo

yum -y install flume-ng
yum -y install flume-ng-agent

umask 022

cat > /tmp/scissor-log.sh << EOF
LOG="/var/log/flume.log"

function log() {
    msg="\`date --iso-8601=ns\` \$1"
    echo "\$msg" >> \$LOG
}
EOF

source /tmp/scissor-log.sh
rm -f $LOG

cd /opt
git clone -b master https://anc-git.salzburgresearch.at/gkatzinger/flume-config.git
log "Cloned flume-config"

cd /opt
mkdir lib-filtered
cd lib-filtered
git clone -b master https://anc-git.salzburgresearch.at/gkatzinger/morphline-lib.git .
log "Cloned morphline-lib"

cd /opt
mkdir zookeeper-agent
cd zookeeper-agent
git clone -b master https://anc-git.salzburgresearch.at/ppaiva/zookeeper-agent.git .
log "Cloned zookeeper-agent"

cd /opt
mkdir zookeeper-lib
cd zookeeper-lib
git clone -b master https://anc-git.salzburgresearch.at/ppaiva/zookeeper-lib.git .
log "Cloned zookeeper-lib"
