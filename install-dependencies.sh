#! /bin/bash

echo -e "\\n##### Install libs #####\\n"

apt-get install -y ruby-dev
apt-get install -y gcc
apt-get install -y make

echo -e "\\n##### Install Docker #####\\n"

curl -sSL https://get.docker.com | sh
usermod -aG docker "$USER"

echo -e "\\n##### Install inspec #####\\n"

gem install inspec -v 2.1.30

echo -e "\\n##### Install docker-compose #####\\n"

curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
