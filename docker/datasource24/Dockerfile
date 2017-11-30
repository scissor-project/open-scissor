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
    g++=4:5.3.1-1ubuntu1 \
    libapr1=1.5.2-3 \
    libapr1-dev=1.5.2-3 \
    libdbi1=0.9.0-4 \
    libperl5.22=5.22.1-9ubuntu0.2 \
    libzmq1=2.2.0+dfsg-7 \
    libzmq-dev=2.2.0+dfsg-7 \
    python-zmq=15.2.0-0ubuntu4 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# There is no cppzmq package for Ubuntu. Let's add the sources from GitHub
RUN \
  wget -q 'https://raw.githubusercontent.com/zeromq/cppzmq/v4.2.2/zmq.hpp' -O /usr/include/zmq.hpp \
  && wget -q 'https://raw.githubusercontent.com/zeromq/cppzmq/v4.2.2/zmq_addon.hpp' -O /usr/include/zmq_addon.hpp \
  && chmod 0644 /usr/include/zmq.hpp \
  && chmod 0644 /usr/include/zmq_addon.hpp

ENV INIT_SCRIPT_PATH /opt/start-datasource24.sh
COPY start-datasource24.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

ENV ZMQ_BASH_PUSH_PATH /opt/zmq-bash-push
RUN \
  mkdir -p "$ZMQ_BASH_PUSH_PATH"
COPY zmq-bash-push/ $ZMQ_BASH_PUSH_PATH

ENV NX_LOG_CE_FILE_NAME nxlog-ce_2.9.1716_ubuntu_1604_amd64.deb
RUN \
  wget -q "https://nxlog.co/system/files/products/files/348/$NX_LOG_CE_FILE_NAME" -O /tmp/"$NX_LOG_CE_FILE_NAME" \
  && dpkg -i /tmp/"$NX_LOG_CE_FILE_NAME" \
  && rm /tmp/"$NX_LOG_CE_FILE_NAME"

ENV FILEBEAT_FILE_NAME filebeat_1.3.1_amd64.deb
RUN \
  wget -q "https://download.elastic.co/beats/filebeat/$FILEBEAT_FILE_NAME" -O /tmp/"$FILEBEAT_FILE_NAME"\
  && dpkg -i /tmp/"$FILEBEAT_FILE_NAME" \
  && rm /tmp/"$FILEBEAT_FILE_NAME"

RUN \
  rm -f /etc/filebeat/*

COPY beats-ds /etc/filebeat

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

RUN mkdir -p "$SCISSOR_LOG_DIR"/filebeat

ENTRYPOINT ["/opt/start-datasource24.sh"]
