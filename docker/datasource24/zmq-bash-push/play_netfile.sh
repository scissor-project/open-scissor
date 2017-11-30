#!/bin/bash



./zmq-send-log.py -d logstash -p 8891 -f envtime -F Streamon.txt
#./zmq-send-log.py -d 172.16.96.105 -p 8890 -f envtime -F Streamon.txt
