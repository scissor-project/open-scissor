#!/bin/bash -xe

# Set values with debconf-set-selections to avoid questions during package installation
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

apt-get install -y \
  default-jre \
  gawk \
  git \
  htop \
  iptables-persistent \
  man	\
  mosh \
  multitail \
  tcpdump \
  telnet \
  tmux \
  vim	\
  zookeeperd
