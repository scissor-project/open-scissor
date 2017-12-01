#!/bin/bash

set -xeuo pipefail
IFS=$'\\n\t'

dnf clean all
rm -rf /var/cache/dnf
