#!/bin/bash

pkill nxlog
sleep 1
: > scada.log
nxlog -f -c favignana-nxlog.conf &

# trap ctrl-c and call ctrl_c()
#trap ctrl_c INT

function ctrl_c() {
        echo -n "Stopping SCADA event transmission..."
	pkill nxlog
	echo "done"
	exit 0
}

sleep 1

while true
do
	head -"$(shuf -i1-10 -n1)" favignana.log >> scada.log
	sleep 1
done
