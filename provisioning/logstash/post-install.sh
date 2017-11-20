#!/bin/bash -ex

cat > /tmp/scissor-log.sh << EOF
LOG="/var/log/logstash.log"

function log() {
    msg="$(date --iso-8601=ns) \"\$1\""
    echo "\$msg" >> \$LOG
}
EOF

# shellcheck disable=SC1091
source /tmp/scissor-log.sh
rm -f "$LOG"
