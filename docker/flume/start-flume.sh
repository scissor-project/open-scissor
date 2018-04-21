#!/bin/sh

flume_configuration_path="$FLUME_CONFIG_PATH/conf"

echo "Waiting for kafka"
while ! nc -vvz kafka 9092; do echo "Wating 10 secs..."; sleep 10; done

echo "Starting flume agents. Configuration path: $flume_configuration_path, output path: $SCISSOR_LOG_DIR"
flume-ng agent -c "$flume_configuration_path"/ingest/ -f "$flume_configuration_path"/ingest/ingest.conf -n ingest > "$SCISSOR_LOG_DIR"/ingest.out 2>&1 &
flume-ng agent -c "$flume_configuration_path"/filter/ -f "$flume_configuration_path"/filter/filter.conf -n filter > "$SCISSOR_LOG_DIR"/filter.out 2>&1 &
flume-ng agent -c "$flume_configuration_path"/output/ -f "$flume_configuration_path"/output/output.conf -n output > "$SCISSOR_LOG_DIR"/output.out 2>&1 &

echo "Starting Zookeeper agent. Configuration path: $ZOOKEEPER_AGENT_PATH, output path: $SCISSOR_LOG_DIR"
java -cp "$ZOOKEEPER_AGENT_PATH"/conf:"$ZOOKEEPER_AGENT_PATH"/lib/* -Dscissor.log.dir="$SCISSOR_LOG_DIR" at.srfg.ccl.zookeeper.ZookeeperBasicAgent &

tail -F \
  "$SCISSOR_LOG_DIR"/ingest.out \
  "$SCISSOR_LOG_DIR"/ingest.log \
  "$SCISSOR_LOG_DIR"/filter.out \
  "$SCISSOR_LOG_DIR"/filter.log \
  "$SCISSOR_LOG_DIR"/output.out \
  "$SCISSOR_LOG_DIR"/output.log \
  "$SCISSOR_LOG_DIR"/scissor-zookeeper.log \
  "$SCISSOR_LOG_DIR"/zookeeper-agent.log
