#!/bin/bash -exe

dnf install -y \
  iptables-services \
  libpreludedb \
  mariadb-server \
  prelude-manager \
  prelude-manager-db-plugin \
  prelude-tools \
  preludedb-mysql \
  preludedb-tools \
  pwgen
