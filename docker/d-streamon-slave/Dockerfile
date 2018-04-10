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

RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    openssh-server=1:7.2p2-4ubuntu2.4 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install -y python

RUN mkdir /var/run/sshd
RUN echo 'root:slave' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]


ENV INIT_SCRIPT_PATH /opt/start-d-streamon-slave.sh
COPY start-d-streamon-slave.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

ENTRYPOINT ["/opt/start-d-streamon-slave.sh"]
