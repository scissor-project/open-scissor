#!/bin/sh

# Wait for prelude-registrator to start
echo "Waiting for kafka to be ready on port 9092"
while ! nc kafka 9092 </dev/null; do echo "Wating 10 secs..."; sleep 10; done

# workaround for tail -F saying: "has been replaced with a remote file. giving up on this name"
truncate -s0 "$SCISSOR_LOG_DIR"/kafka-idmef-converter-output.log;

converter > "$SCISSOR_LOG_DIR"/kafka-idmef-converter-output.log 2>&1 &

tail -F \
  "$SCISSOR_LOG_DIR"/kafka-idmef-converter-output.log
