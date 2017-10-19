#!/bin/bash -xe

yum install epel-release

yum clean all
rm -rf /var/cache/yum
