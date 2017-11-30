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

# Install zookeeper specific packages
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    git=1:2.7.4-0ubuntu1.3 \
    zookeeperd=3.4.8-1 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /etc/zookeeper/conf

RUN \
  git init . \
  && git remote add -t \* -f origin https://anc-git.salzburgresearch.at/gkatzinger/zookeeperd-config.git \
  && git checkout -f master

RUN mkdir -p /opt/zookeeper-lib
WORKDIR /opt/zookeeper-lib
RUN git clone -b master https://anc-git.salzburgresearch.at/ppaiva/zookeeper-lib.git .

RUN mkdir -p /opt/zookeeper-master
WORKDIR /opt/zookeeper-master
RUN \
  git clone -b master https://anc-git.salzburgresearch.at/ppaiva/zookeeper-master.git .

COPY start-zookeeper.sh /opt/zookeeper-master/bin/

EXPOSE 2181

RUN chmod a+x /opt/zookeeper-master/bin/start-zookeeper.sh
ENTRYPOINT ["/opt/zookeeper-master/bin/start-zookeeper.sh"]
