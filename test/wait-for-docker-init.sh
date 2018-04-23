#!/bin/sh -e

# source: https://www.marksayson.com/blog/wait-until-docker-containers-initialized/


# Return true-like values if and only if logs
# contain the expected "ready" line

datasource24IsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "...done."
}

dStreamonMasterIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Zmq Proxy ready" \
  && docker-compose --file "$2" logs "$1" | grep -q "D-streamon listening on port 9999" \
  && docker-compose --file "$2" logs "$1" | grep -q "Finished 'watch' after" \
  && docker-compose --file "$2" logs "$1" | grep -q "Running Swagger Editor API server. You can make GET and PUT calls to"
}

dStreamonSlaveIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "...done."
}

eventCorrelatorIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Successful registration to prelude-manager"
}

flumeIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "New I/O server boss" \
  && docker-compose --file "$2" logs "$1" | grep -q "New I/O worker"
}

kafkaIdmefConverterReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Ncat: Connected to"
}

kafkaIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Auto creation of topic"
}

kafkaPreludeConnectorIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Successful registration to prelude-manager"
}

logstashIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "logstash started."
}

preludeManagerIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Created profile 'prelude-manager'"
}

prewikkaIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "resuming normal operations"
}

rawDataAnalyzerIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Writing to topic IDMEF"
}

semanticsIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "enrich_semantics.conf" \
  && docker-compose --file "$2" logs "$1" | grep -q "xform_semantics.conf"
}

zookeeperIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "State change: CONNECTED"
}



waitUntilServiceIsReady () {
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
