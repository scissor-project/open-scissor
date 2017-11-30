#!/bin/bash



#./zmq-send-log.py -d 172.16.96.105 -p 8891 -f time -F Stazionario_1_trans.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F Stazionario_1_trans.txt
./zmq-send-log.py -d logstash -p 8891 -f time -F Stazionario_1_trans_single_val.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F Stazionario_1_repeat.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F single_spaced_events.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F single_1s_events.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F 10_events_per_s.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F 10_events_per_s_2val.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F Stazionario_1_repeat.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F filter_events.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F many_sensors_events.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F many_sensors_events-pd.txt
#./zmq-send-log.py -d logstash -p 8891 -f time -F test_events_pedro.txt
