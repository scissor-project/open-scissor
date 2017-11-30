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

ENV KAFKA_HOME /opt/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin

RUN mkdir -p "$KAFKA_HOME"
WORKDIR $KAFKA_HOME

ENV KAFKA_FILENAME="kafka_2.10-0.8.2.2.tgz"
RUN \
  wget -q "https://archive.apache.org/dist/kafka/0.8.2.2/$KAFKA_FILENAME" \
  && tar -xvzf "$KAFKA_FILENAME" --strip 1 \
  && rm "$KAFKA_FILENAME"

COPY start-kafka.sh /opt/kafka/bin/
COPY log4j.properties /opt/kafka/conf/

EXPOSE 9092

RUN chmod a+x /opt/kafka/bin/start-kafka.sh
ENTRYPOINT ["/opt/kafka/bin/start-kafka.sh"]
