#!/bin/bash -ex
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
LOG="/var/log/flume-semantics.log"

function log() {
    msg="$(date --iso-8601=ns) \"\$1\""
    echo "\$msg" >> \$LOG
}
EOF

# shellcheck disable=SC1091
source /tmp/scissor-log.sh
rm -f "$LOG"

cd /opt
git clone -b master https://anc-git.salzburgresearch.at/qtango/flume-config.git
#git clone -b master https://anc-git.salzburgresearch.at/gkatzinger/flume-config.git
log "Cloned flume-config from qtango for semantics"

cd /opt
mkdir lib-filtered
cd lib-filtered
#git clone -b master https://anc-git.salzburgresearch.at/gkatzinger/morphline-lib.git .
git clone -b master https://anc-git.salzburgresearch.at/qtango/morphline-lib.git .
log "Cloned morphline-lib from qtango for semantics"
