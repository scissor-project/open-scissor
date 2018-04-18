#!/bin/sh

flume_configuration_path="$FLUME_CONFIG_PATH/conf"

echo "Wait for flume to start"
while ! nc flume 10000 </dev/null; do echo "Wating 10 secs..."; sleep 10; done
while ! nc flume 20000 </dev/null; do echo "Wating 10 secs..."; sleep 10; done

echo "Starting flume agents. Configuration path: $flume_configuration_path, output path: $SCISSOR_LOG_DIR"
flume-ng agent -c "$flume_configuration_path"/enrich_semantics/ -f "$flume_configuration_path"/enrich_semantics/enrich_semantics.conf -n enrich_semantics -Dflume.root.logger=ERROR,console > "$SCISSOR_LOG_DIR"/enrich_semantics.out 2>&1 &
flume-ng agent -c "$flume_configuration_path"/xform_semantics/ -f "$flume_configuration_path"/xform_semantics/xform_semantics.conf -n xform_semantics -Dflume.root.logger=ERROR,console > "$SCISSOR_LOG_DIR"/xform_semantics.out 2>&1 &

tail -F \
  "$SCISSOR_LOG_DIR"/enrich_semantics.out \
  "$SCISSOR_LOG_DIR"/enrich_semantics.log \
  "$SCISSOR_LOG_DIR"/xform_semantics.out \
  "$SCISSOR_LOG_DIR"/xform_semantics.log
