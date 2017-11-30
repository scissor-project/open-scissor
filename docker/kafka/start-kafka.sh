#!/bin/sh

# Set the external host and port
if [ ! -z "$ADVERTISED_HOST" ]; then
    echo "advertised host: $ADVERTISED_HOST"
    sed -r -i "s/#(advertised.host.name)=(.*)/\\1=$ADVERTISED_HOST/g" "$KAFKA_HOME"/config/server.properties
fi
if [ ! -z "$ADVERTISED_PORT" ]; then
    echo "advertised port: $ADVERTISED_PORT"
    sed -r -i "s/#(advertised.port)=(.*)/\\1=$ADVERTISED_PORT/g" "$KAFKA_HOME"/config/server.properties
fi

# Set the zookeeper host and port
if [ ! -z "$ZOOKEEPER_HOST" ]; then
    echo "zookeeper host: $ZOOKEEPER_HOST"
    sed -r -i "s/(zookeeper.connect)=(.*)/\\1=$ZOOKEEPER_HOST/g" "$KAFKA_HOME"/config/server.properties
fi

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\\1=$LOG_RETENTION_HOURS/g" "$KAFKA_HOME"/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\\1=$LOG_RETENTION_BYTES/g" "$KAFKA_HOME"/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\\1=$NUM_PARTITIONS/g" "$KAFKA_HOME"/config/server.properties
fi

# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> "$KAFKA_HOME"/config/server.properties
fi

echo "Starting kafka"
"$KAFKA_HOME"/bin/kafka-server-start.sh "$KAFKA_HOME"/config/server.properties &

echo $! > kafka.pid

if [ ! -z "$TOPICS" ]; then
  echo "Waiting for kafka brokers to be ready"
  sleep 10
  echo "Creating topics: $TOPICS"
  for topic in $(echo "$TOPICS" | tr "," "\\n")
  do
    echo "Creating topic $topic"
    "$KAFKA_HOME"/bin/kafka-topics.sh --zookeeper zookeeper:2181 --create --topic "$topic" --partitions 1 --replication-factor 1
  done
fi

tail -F "$KAFKA_HOME"/logs/server.log
