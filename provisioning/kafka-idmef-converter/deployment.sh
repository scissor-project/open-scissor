#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

kafka_server="$3"

kafka_port="9092"
consumer_topics="cam, env, net, scada"
producer_topic="IDMEF"

sed \
    -e "s/__KAFKA_SERVER__/${kafka_server}/g" \
    -e "s/__KAFKA_PORT__/${kafka_port}/g" \
    -e "s/__CONSUMER_TOPICS__/${consumer_topics}/g" \
    -e "s/__PRODUCER_TOPIC__/${producer_topic}/g" \
    -i /etc/converter.conf

systemctl restart converter
