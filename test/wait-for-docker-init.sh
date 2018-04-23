#!/bin/sh -e

# source: https://www.marksayson.com/blog/wait-until-docker-containers-initialized/


# Return true-like values if and only if logs
# contain the expected "ready" line

datasource24_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "...done."
}

d_streamon_master_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "Zmq Proxy ready" \
  && docker-compose --file "$2" logs "$1" | grep -q "D-streamon listening on port 9999" \
  && docker-compose --file "$2" logs "$1" | grep -q "Finished 'watch' after" \
  && docker-compose --file "$2" logs "$1" | grep -q "Running Swagger Editor API server. You can make GET and PUT calls to"
}

d_streamon_slave_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "...done."
}

event_correlator_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "Successful registration to prelude-manager"
}

flume_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "New I/O server boss" \
  && docker-compose --file "$2" logs "$1" | grep -q "New I/O worker"
}

kafka_idmef_converter_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "Ncat: Connected to"
}

kafka_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "Auto creation of topic"
}

kafka_prelude_connector_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "Successful registration to prelude-manager"
}

logstash_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "logstash started."
}

logstash24_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "logstash started."
}

prelude_manager_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "Created profile 'prelude-manager'"
}

prelude_manager_db_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "mysqld: ready for connections"
}

prewikka_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "resuming normal operations"
}

raw_data_analyzer_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "Ncat: Connected"
}

semantics_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "enrich_semantics.conf" \
  && docker-compose --file "$2" logs "$1" | grep -q "xform_semantics.conf"
}

zookeeper_is_ready () {
  docker-compose --file "$2" logs "$1" | grep -q "State change: CONNECTED"
}

wait_until_service_is_ready () {
  attempt=1
  # Max query attempts before consider setup failed
  MAX_TRIES="$4"
  while [ "$attempt" -le "$MAX_TRIES" ]; do
    if "$@"; then
      echo "$2 container is up!"
      break
    fi
    attempt="$((attempt+1))"
    echo "Waiting for $2 container... (attempt: $attempt)"
    sleep 10
  done

  if [ "$attempt" -gt "$MAX_TRIES" ]; then
    echo "Error: $2 not responding, cancelling set up"
    exit 1
  fi
}
