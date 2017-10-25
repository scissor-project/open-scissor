#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

pip install --upgrade pip
pip install kafka

cat <<EOF > /etc/connector.conf
[Config]
kafka_server = __KAFKA_SERVER__
kafka_port = __KAFKA_PORT__
consumer_topic = __CONSUMER_TOPIC__
prelude_profile = __PRELUDE_PROFILE__
EOF

useradd -r -s /sbin/nologin -G prelude connector

# don't start it yet, it is not configured
systemctl enable connector
