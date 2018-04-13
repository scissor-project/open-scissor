#!/bin/sh -e

# source: https://www.marksayson.com/blog/wait-until-docker-containers-initialized/

# Max query attempts before consider setup failed
MAX_TRIES=5

# Return true-like values if and only if logs
# contain the expected "ready" line
dStreamonMasterIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "Zmq Proxy ready" \
  && docker-compose --file "$2" logs "$1" | grep -q "D-streamon listening on port 9999" \
  && docker-compose --file "$2" logs "$1" | grep -q "Finished 'watch' after" \
  && docker-compose --file "$2" logs "$1" | grep -q "Running Swagger Editor API server. You can make GET and PUT calls to"
}

dStreamonSlaveIsReady () {
  docker-compose --file "$2" logs "$1" | grep -q "...done."
}

waitUntilServiceIsReady () {
  attempt=1
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
