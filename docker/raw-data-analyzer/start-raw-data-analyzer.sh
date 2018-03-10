#!/bin/sh

# Wait for prelude-registrator to start
echo "Waiting for kafka to be ready on port 9092"
while ! ncat -vvz kafka 9092; do echo "Wating 10 secs..."; sleep 10; done

# workaround for tail -F saying: "has been replaced with a remote file. giving up on this name"
truncate -s0 "$SCISSOR_LOG_DIR"/raw-data-analyzer-output.log;

sh -c "converter /etc/envMonAnalyzer.conf" > "$SCISSOR_LOG_DIR"/raw-data-analyzer-output.log 2>&1 &

tail -F \
  "$SCISSOR_LOG_DIR"/raw-data-analyzer-output.log
