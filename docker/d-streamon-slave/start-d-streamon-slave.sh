#!/bin/sh

sleep infinity
tail -F \
  "$SCISSOR_LOG_DIR"/streamon.log \
  "$SCISSOR_LOG_DIR"/gulp.log \
  "$SCISSOR_LOG_DIR"/swagger.log \
  /var/log/mongodb/mongodb.log
