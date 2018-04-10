#! /bin/bash

echo -e "\\n##### Install libs #####\\n"

sudo apt install -y ruby-dev
sudo apt install -y gcc
sudo apt install -y make

echo -e "\\n##### Install Docker #####\\n"

curl -sSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

echo -e "\\n##### Install inspec -v 1.49.2 #####\\n"

sudo gem install inspec -v 1.49.2

echo -e "\\n##### Install docker-compose #####\\n"

sudo curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
