#!/bin/sh

# Enable and start mongodb
systemctl enable mongodb.service
service mongodb restart

echo "Waiting for mongodb to start"
while ! nc -vvz localhost 27017; do echo "Wating 10 secs..."; sleep 10; done

# shellcheck source=/dev/null
. "$NVM_DIR"/nvm.sh \
&& node "$D_STREAMON_PATH"/bin/server.js > "$SCISSOR_LOG_DIR"/streamon.log 2>&1 &

# shellcheck source=/dev/null
. "$NVM_DIR"/nvm.sh \
&& gulp watch > "$SCISSOR_LOG_DIR"/gulp.log 2>&1 &

# shellcheck source=/dev/null
. "$NVM_DIR"/nvm.sh \
&& swagger project edit -s --host 0.0.0.0 -p 3000 > "$SCISSOR_LOG_DIR"/swagger.log 2>&1 &

tail -F \
  "$SCISSOR_LOG_DIR"/streamon.log \
  "$SCISSOR_LOG_DIR"/gulp.log \
  "$SCISSOR_LOG_DIR"/swagger.log \
  /var/log/mongodb/mongodb.log

echo "Waiting for node to be ready"
while ! nc -vvz localhost 3000; do echo "Wating 10 secs..."; sleep 10; done
while ! nc -vvz localhost 5570; do echo "Wating 10 secs..."; sleep 10; done
while ! nc -vvz localhost 9999; do echo "Wating 10 secs..."; sleep 10; done
