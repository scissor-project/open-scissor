#!/bin/sh -e

if which inspec >/dev/null 2>&1 ; then
  echo "inspec is already installed"
else
  wget -O /tmp/inspec.deb https://packages.chef.io/files/stable/inspec/1.46.2/ubuntu/16.04/inspec_1.46.2-1_amd64.deb
  dpkg -i /tmp/inspec.deb
fi
