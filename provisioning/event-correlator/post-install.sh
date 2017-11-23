#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

git clone git://github.com/scissor-project/prelude-correlator
cd prelude-correlator || exit
python setup.py install
cd ..

# Add the profile to use in the service file
cat <<EOF > /usr/lib/systemd/system/prelude-correlator.service
[Unit]
Description=Prelude-Correlator service
DefaultDependencies=no
After=remode_fs.target prelude-manager.service

[Service]
ExecStart=/usr/bin/prelude-correlator -d -P /run/prelude-correlator/prelude-correlator.pid --profile=__PRELUDE_PROFILE__
Type=forking
PIDFile=/run/prelude-correlator/prelude-correlator.pid
Restart=always
User=prelude-correlator
Group=prelude

[Install]
WantedBy=multi-user.target
EOF


# don't start it yet, it is not configured
systemctl enable prelude-correlator

useradd prelude-correlator -g prelude
mkdir /run/prelude-correlator
chown -R prelude-correlator:prelude /run/prelude-correlator
