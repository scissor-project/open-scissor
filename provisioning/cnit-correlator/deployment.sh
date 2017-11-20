#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

prelude_profile="prelude-correlator"
prelude_registrator_passwd="password"
prelude_manager_host="$3"

sed -e "s/^server-addr = 127.0.0.1$/server-addr = ${prelude_manager_host}/" -i /etc/prelude/default/client.conf
sed -e "s/__PRELUDE_PROFILE__/${prelude_profile}/g" -i /usr/lib/systemd/system/prelude-correlator.service
systemctl daemon-reload

prelude-admin register "${prelude_profile}" "idmef:rw" "${prelude_manager_host}" --uid prelude-correlator --gid prelude --passwd "${prelude_registrator_passwd}"

systemctl restart prelude-correlator
