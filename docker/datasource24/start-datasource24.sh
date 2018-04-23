#!/bin/sh

echo "Waiting for external dependencies to start"
while ! nc -vvz logstash 8892; do echo "Wating 10 secs..."; sleep 10; done
while ! nc -vvz kafka 9092; do echo "Wating 10 secs..."; sleep 10; done
while ! nc -vvz zookeeper 2181; do echo "Wating 10 secs..."; sleep 10; done

systemctl enable filebeat.service
service filebeat restart

tail -F \
  "$SCISSOR_LOG_DIR"/filebeat.log \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat.1 \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat.2 \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat.3 \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat.4 \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat.5 \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat.6 \
  "$SCISSOR_LOG_DIR"/filebeat/filebeat.7 \
  /var/log/nxlog/nxlog.log
