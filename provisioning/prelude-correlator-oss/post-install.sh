#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

# don't start it yet, it is not configured
systemctl enable prelude-correlator
