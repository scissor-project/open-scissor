#!/bin/sh

# Enable and start mongodb
systemctl enable mongodb.service
service mongodb restart

# shellcheck source=/dev/null
. "$NVM_DIR"/nvm.sh \
&& node "$D_STREAMON_PATH"/bin/server.js > "$SCISSOR_LOG_DIR"/streamon.log 2>&1 &

# shellcheck source=/dev/null
. "$NVM_DIR"/nvm.sh \
&& gulp watch > "$SCISSOR_LOG_DIR"/gulp.log 2>&1 &

# shellcheck source=/dev/null
. "$NVM_DIR"/nvm.sh \
&& swagger project edit -s --host 0.0.0.0 -p 3000 > "$SCISSOR_LOG_DIR"/swagger.log 2>&1 &

echo "Waiting for node to be ready"
while ! nc localhost 3000 </dev/null; do echo "Wating 10 secs..."; sleep 10; done
while ! nc localhost 5570 </dev/null; do echo "Wating 10 secs..."; sleep 10; done
while ! nc localhost 9999 </dev/null; do echo "Wating 10 secs..."; sleep 10; done

tail -F \
  "$SCISSOR_LOG_DIR"/streamon.log \
  "$SCISSOR_LOG_DIR"/gulp.log \
  "$SCISSOR_LOG_DIR"/swagger.log \
  /var/log/mongodb/mongodb.log
