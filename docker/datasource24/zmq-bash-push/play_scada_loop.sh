#!/bin/bash


# trap ctrl-c and call ctrl_c()
#trap ctrl_c INT

function ctrl_c() {
        echo -n "Stopping SCADA event transmission..."
	echo "done"
	exit 0
}

sleep 1

while true
do
	head -"$(shuf -i1-10 -n1)" favignana.log >> /tmp/scada.log
	head -"$(shuf -i1-10 -n1)" scada-error.log >> /tmp/scada-error.log
	head -"$(shuf -i1-10 -n1)" scada-process-alarm.log >> /tmp/scada-process-alarm.log
	sleep 3
done
