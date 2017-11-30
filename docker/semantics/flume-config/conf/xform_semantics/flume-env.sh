#!/bin/sh

# If this file is placed at FLUME_CONF_DIR/flume-env.sh, it will be sourced
# during Flume startup.

# Enviroment variables can be set here.

export JAVA_OPTS="-Xms256m -Xmx1024m -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=5067 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=semantics -Dscissor.log.dir=$SCISSOR_LOG_DIR"

# Note that the Flume conf directory is always included in the classpath.
FLUME_CLASSPATH="/opt/morphline-lib/*"

echo "Flume classpath test to $FLUME_CLASSPATH"
