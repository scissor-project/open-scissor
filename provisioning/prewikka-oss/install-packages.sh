#!/bin/bash -xe

yum install -y \
  prewikka \
  httpd \
  mariadb-server \
  mod_wsgi \
  preludedb-mysql \
  pwgen
