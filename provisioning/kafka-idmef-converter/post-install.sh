#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

pip install --upgrade pip
pip install kafka

cat <<EOF > /etc/converter.conf
[Config]

kafka_server = __KAFKA_SERVER__
kafka_port = __KAFKA_PORT__

# topics the consumer will subscribe
consumer_topics = __CONSUMER_TOPICS__

# topic where the IDMEF will be sent
producer_topic = __PRODUCER_TOPIC__
EOF

systemctl enable converter
