#!/bin/bash -xe

wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elasticsearch.org/logstash/2.4/debian stable main" | sudo tee -a /etc/apt/sources.list
apt-get update -y
