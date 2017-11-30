#!/bin/bash

LOGSTASH_IP=logstash

TOTAL_FAIL=0

# start kafka consumer and save output
/opt/kafka/bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --whitelist 'env|scada|net|cam' > kafka.txt 2> /dev/null &
PID=$!

# it's necessary to sleep a few seconds to give the consumer time to start up
sleep 30

#../zmq-send-log.py -d ${LOGSTASH_IP} -p 8891 -f time -F data/oldenv.txt
../zmq-send-log.py -d ${LOGSTASH_IP} -p 8893 -f newenv -F data/env.txt
../zmq-send-log.py -d ${LOGSTASH_IP} -p 8892 -f envtime -F data/cam.txt
cp data/scada.txt /tmp/scada.log

sleep 30

kill -TERM $PID


function evaluate() {
    topic=$1
    needle="SCISSOR_TEST_SENSOR_$topic"
    sent="$(grep -ic "$needle" data/"${topic}".txt)"
    rcvd="$(grep -ic "$needle" kafka.txt)"
    if [ "$sent" -eq "$rcvd" ]
    then
        verdict="PASSED"
    else
        verdict="FAILED"
        ((TOTAL_FAIL++))
    fi
    echo "$topic: $verdict (${rcvd}/${sent})"

}

evaluate env
evaluate cam
evaluate scada

exit "$TOTAL_FAIL"
