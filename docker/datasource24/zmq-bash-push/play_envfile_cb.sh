#!/bin/bash

if [ "$#" -ne 1 ]
then
    echo "usage: $0 file"
    echo "e.g. $0 env-favignana/Test_new_format_10_events.txt"
    exit 1
fi

FILE="$1"

trap 'exit 1' 2

echo "Will now replay $FILE"
echo -e "STATS\\n-----"
./env-stat.sh "$FILE"


./zmq-send-log.py -s 100 -d 10.10.1.45 -p 8893 -f newenv -F "$FILE"

#./zmq-send-log.py -d 172.16.96.105 -p 8891 -f time -F Stazionario_1_trans.txt
#./zmq-send-log.py -d 10.10.1.45 -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d 10.10.1.45 -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d 10.10.1.45 -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d 10.10.1.45 -p 8891 -f time -F env-favignana/UnAuthorized_Access_1_snapshot_trans.txt
#./zmq-send-log.py -d 10.10.1.45 -p 8891 -f time -F Stazionario_1_trans.txt
#./zmq-send-log.py -d 172.16.96.105 -p 8891 -f time -F Stazionario_1_repeat.txt
