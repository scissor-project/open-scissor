#!/bin/bash

set -xeuo pipefail
IFS=$'\\n\t'

yum install -y epel-release

yum clean all
rm -rf /var/cache/yum
