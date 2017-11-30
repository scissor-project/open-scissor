#!/bin/bash

trap 'exit 1' 2


./zmq-send-log.py -d logstash -p 8893 -f newenv -F env-favignana/Test_new_format.txt

#./zmq-send-log.py -d 172.16.96.105 -p 8891 -f time -F Stazionario_1_trans.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F Stazionario_1_trans.txt
#./zmq-send-log.py -d 172.16.96.105 -p 8891 -f time -F Stazionario_1_repeat.txt
