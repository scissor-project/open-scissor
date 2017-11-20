#!/bin/bash -exe

yum install -y epel-release

yum clean all
rm -rf /var/cache/yum
