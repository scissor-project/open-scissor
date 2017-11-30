#!/bin/sh

# If this file is placed at FLUME_CONF_DIR/flume-env.sh, it will be sourced
# during Flume startup.

# Enviroment variables can be set here.

# Give Flume more memory and pre-allocate, enable remote monitoring via JMX
export JAVA_OPTS="-Xms100m -Xmx2000m -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=5445 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=flume -Dscissor.log.dir=$SCISSOR_LOG_DIR"

# Note that the Flume conf directory is always included in the classpath.
FLUME_CLASSPATH="/opt/morphline-lib/*"

echo "Flume classpath test to $FLUME_CLASSPATH"
