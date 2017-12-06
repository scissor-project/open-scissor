#!/bin/bash

set -xeuo pipefail
IFS=$'\\n\t'

pip install --upgrade pip
pip install kafka

cat <<EOF > /etc/converter.conf
kafka_server: __KAFKA_SERVER__
kafka_port: __KAFKA_PORT__

consumer_topics: [__CONSUMER_TOPICS__]

producer_topic: __PRODUCER_TOPIC__

block_filters : []
EOF

systemctl enable converter
