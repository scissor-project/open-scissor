#!/bin/sh

systemctl enable logstash.service
service logstash restart

tail -F \
  "$SCISSOR_LOG_DIR"/logstash_output.txt
