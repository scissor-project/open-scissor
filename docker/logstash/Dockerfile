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
  echo "deb http://packages.elasticsearch.org/logstash/1.5/debian stable main" | tee -a /etc/apt/sources.list \
  && wget -q 'https://packages.elasticsearch.org/GPG-KEY-elasticsearch' -O archive.key \
  && apt-key add archive.key \
  && rm archive.key

# Install logstash specific packages
# Set values with debconf-set-selections to avoid questions during package installation
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    libzmq3-dev=4.1.4-7 \
    logstash=1:1.5.6-1 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY logstash-config/syslogng.conf /etc/logstash/conf.d/syslogng.conf
RUN chmod 0664 /etc/logstash/conf.d/syslogng.conf

COPY logrotate-config/logrotate.conf /etc/logrotate.conf
RUN chmod 0664 /etc/logrotate.conf

RUN cp /etc/cron.daily/logrotate /etc/cron.hourly

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

ENV INIT_SCRIPT_PATH /opt/start-logstash.sh
COPY start-logstash.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

EXPOSE 8892 8893

ENTRYPOINT ["/opt/start-logstash.sh"]
