#!/bin/bash -x

cat > /tmp/scissor-log.sh << EOF
LOG="/var/log/logstash.log"

function log() {
    msg="\`date --iso-8601=ns\` \$1"
    echo "\$msg" >> \$LOG
}
EOF

source /tmp/scissor-log.sh
rm -f $LOG
