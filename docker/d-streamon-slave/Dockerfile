FROM ubuntu:16.04

LABEL maintainer "ferrari.marco@gmail.com"

RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    default-jre=2:1.8-56ubuntu2 \
    iproute2=4.3.0-1ubuntu3 \
    net-tools=1.60-26ubuntu1 \
    netcat=1.10-41 \
    wget=1.17.1-1ubuntu1.3 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    libboost-dev=1.58.0.1ubuntu1 \
    libpcap-dev=1.7.4-2 \
    libzmq3-dev=4.1.4-7 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ENV INIT_SCRIPT_PATH /opt/start-d-streamon-slave.sh
COPY start-d-streamon-slave.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

ENTRYPOINT ["/opt/start-d-streamon-slave.sh"]
