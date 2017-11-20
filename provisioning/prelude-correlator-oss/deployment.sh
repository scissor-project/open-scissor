#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

prelude_manager_host="$3"

prelude_profile="prelude-correlator"
prelude_registrator_passwd="password"

sed -e "s/^server-addr = 127.0.0.1$/server-addr = ${prelude_manager_host}/" -i /etc/prelude/default/client.conf

prelude-admin register "${prelude_profile}" "idmef:rw" "${prelude_manager_host}" --uid prelude-correlator --gid prelude --passwd "${prelude_registrator_passwd}"

# Disable default plugins
mkdir /etc/prelude-correlator/rules/python_disabled
find /etc/prelude-correlator/rules/python -type f ! -name __init__.py -exec mv {} /etc/prelude-correlator/rules/python_disabled \;

# Setup test plugin
cat <<EOF > /etc/prelude-correlator/rules/python/TestPlugin.py
from preludecorrelator.context import Context
from preludecorrelator.pluginmanager import Plugin
from preludecorrelator import log

logger = log.getLogger(__name__)

class TestPlugin(Plugin):
    def __init__(self, env):
        logger.info("Loading %s", TestPlugin)

    def run(self, idmef):
        text = idmef.get("alert.classification.text")

        if not text:
            return

        ctx = Context(("TEST RULE", text), { "expire": 30, "threshold": 3, "alert_on_expire": True }, update = True, idmef=idmef)
        if ctx.getUpdateCount() == 0:
            ctx.set("alert.correlation_alert.name", "Test message spammed")
            ctx.set("alert.classification.text", "TestPlugin")
            ctx.set("alert.assessment.impact.severity", "info")
EOF
chown prelude-correlator:prelude /etc/prelude-correlator/rules/python/TestPlugin.py
chmod 660 /etc/prelude-correlator/rules/python/TestPlugin.py

systemctl restart prelude-correlator
