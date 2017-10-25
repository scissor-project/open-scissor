#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

kafka_server="10.10.1.50"
kafka_port="9092"
consumer_topic="IDMEF"
prelude_profile="connector"
prelude_registrator_passwd="password"
prelude_manager_host="10.10.1.60"

sed \
    -e "s/__KAFKA_SERVER__/${kafka_server}/g" \
    -e "s/__KAFKA_PORT__/${kafka_port}/g" \
    -e "s/__CONSUMER_TOPIC__/${consumer_topic}/g" \
    -e "s/__PRELUDE_PROFILE__/${prelude_profile}/g" \
    -i /etc/connector.conf

sed -e "s/^server-addr = 127.0.0.1$/server-addr = ${prelude_manager_host}/" -i /etc/prelude/default/client.conf

prelude-admin register "${prelude_profile}" "idmef:w" "${prelude_manager_host}" --uid connector --gid connector --passwd "${prelude_registrator_passwd}"
service connector restart
