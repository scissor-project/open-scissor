#!/bin/bash -x

umask 022

source /tmp/scissor-log.sh

SEMANTICS_IP="$1"
NODE_NAME="$2"

# this is the semantics VM not the other flume VM with ingest agent
FLUME_IP="$3"

hostnamectl set-hostname $NODE_NAME

# add new hostname to /etc/hosts
sed -i "/^127\.0\.0\.1/ s/\$/ $NODE_NAME/" /etc/hosts





#semantics does not using ingest, but it is there for testing
#sed -i "s/10\.0\.1\.67/$FLUME_IP/g" /opt/flume-config/conf/ingest/ingest.conf

#flume VM should bind with semantics on port 20000
#
sed -i "s/10\.0\.1\.67/$SEMANTICS_IP/g" /opt/flume-config/conf/enrich_semantics/enrich_semantics.conf
sed -i "s/localhost/$FLUME_IP/g" /opt/flume-config/conf/enrich_semantics/enrich_semantics.conf
sed -i "s/25000/10000/g" /opt/flume-config/conf/enrich_semantics/enrich_semantics.conf

sed -i "s/10\.0\.1\.67/$SEMANTICS_IP/g" /opt/flume-config/conf/enrich_semantics/flume-env.sh

sed -i "s/10\.0\.1\.67/$SEMANTICS_IP/g" /opt/flume-config/conf/xform_semantics/xform_semantics.conf
sed -i "s/localhost/$FLUME_IP/g" /opt/flume-config/conf/xform_semantics/xform_semantics.conf
sed -i "s/35000/20000/g" /opt/flume-config/conf/xform_semantics/xform_semantics.conf

sed -i "s/10\.0\.1\.67/$SEMANTICS_IP/g" /opt/flume-config/conf/xform_semantics/flume-env.sh

cd /opt/flume-config
chmod u+x bin/*.sh
./bin/kill-and-start-flume-semantics-agents.sh
log "Started flume semantics agents, not injest or filter"

cd /opt
git clone https://anc-git.salzburgresearch.at/cbrand/linux-config.git
/opt/linux-config/deploy/deploy.sh
/opt/linux-config/deploy/deploy-scissor.sh
log "Deployed linux-config"

git config --global color.ui auto

log "Host $NODE_NAME (semantics) ready on ${SEMANTICS_IP} (attached to ANC FLUME on ${FLUME_IP})"
