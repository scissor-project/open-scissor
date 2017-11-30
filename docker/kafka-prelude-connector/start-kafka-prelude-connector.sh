#!/bin/sh

# Wait for prelude-registrator to start
echo "Waiting for kafka to be ready on port 9092"
while ! nc kafka 9092 </dev/null; do echo "Wating 10 secs..."; sleep 10; done

echo "Waiting for prelude-registrator to be ready on port 5553"
while ! nc prelude-manager 5553 </dev/null; do echo "Wating 10 secs..."; sleep 10; done

prelude-admin register "$PRELUDE_PROFILE" "idmef:w" prelude-manager --uid connector --gid connector --passwd "password"

# workaround for tail -F saying: "has been replaced with a remote file. giving up on this name"
truncate -s0 "$SCISSOR_LOG_DIR"/kafka-prelude-connector.log;

connector > "$SCISSOR_LOG_DIR"/kafka-prelude-connector.log 2>&1 &

tail -F \
  "$SCISSOR_LOG_DIR"/kafka-prelude-connector.log
