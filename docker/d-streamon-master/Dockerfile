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
    ansible=2.0.0.2-2ubuntu1 \
    build-essential=12.1ubuntu2 \
    cmake=3.5.1-1ubuntu3 \
    curl=7.47.0-1ubuntu2.7 \
    g++=4:5.3.1-1ubuntu1 \
    git=1:2.7.4-0ubuntu1.3 \
    libboost-dev=1.58.0.1ubuntu1 \
    libpcap-dev=1.7.4-2 \
    libpugixml-dev=1.7-2 \
    libssl-dev=1.0.2g-1ubuntu4.12 \
    libzmq3-dev=4.1.4-7 \
    mongodb-server=1:2.6.10-0ubuntu1 \
    redis-server=2:3.0.6-1 \
    openssh-client=1:7.2p2-4ubuntu2.4 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /usr/local/nvm
ENV NVM_VERSION 0.33.8
RUN curl -o- "https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh" | bash

ENV D_STREAMON_PATH /opt/d-streamon
RUN mkdir -p "$D_STREAMON_PATH"
COPY d-streamon/ $D_STREAMON_PATH

ENV STREAMON_PATH /opt/d-streamon/streamon

WORKDIR $STREAMON_PATH

RUN \
  cmake . \
  && make

WORKDIR $D_STREAMON_PATH

RUN \
  . "$NVM_DIR"/nvm.sh \
  && nvm install v0.10.25 \
  && npm config set registry="http://registry.npmjs.org/" \
  && npm install --unsafe-perm \
  && npm install --global gulp@3.9.1 \
  && npm install --global swagger@0.6.0

RUN apt update && apt install -y sshpass

RUN echo -e "[defaults]\\nhost_key_checking = False" > /etc/ansible/ansible.cfg

RUN ssh-keygen -N "" -f "$HOME"/.ssh/id_rsa

RUN sed -ie 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config


ENV INIT_SCRIPT_PATH /opt/start-d-streamon-master.sh
COPY start-d-streamon-master.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

EXPOSE 3000 5570 9999 27017

ENTRYPOINT ["/opt/start-d-streamon-master.sh"]
