#!/bin/sh

echo "Starting zookeeper service"
service zookeeper restart

echo "Starting ZookeeperCCA"
java -cp /opt/zookeeper-master/conf:/opt/zookeeper-lib/* -Dscissor.log.dir=/opt/zookeeper-master/log at.srfg.ccl.zookeeper.ZookeeperCCA &
tail -F /opt/zookeeper-master/log/master.log
