#!/bin/bash

trap 'exit 1' 2

while true
do
./zmq-send-log.py -d logstash -p 8893 -f newenv -F env-favignana/Test_new_format.txt
done
