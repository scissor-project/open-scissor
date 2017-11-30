#!/bin/bash

trap 'exit 1' 2

while true
do
./zmq-send-log.py -d logstash -p 8892 -f envtime -F Camera1.txt
sleep 1
done
