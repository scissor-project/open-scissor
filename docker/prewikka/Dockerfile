FROM fedora:26

LABEL maintainer "ferrari.marco@gmail.com"

RUN \
  dnf check-update \
  ; dnf install -y \
    hostname-3.18-2.fc26 \
    httpd-2.4.25-8.fc26 \
    iproute-4.11.0-1.fc26 \
    libpreludedb-3.1.0-2.fc26 \
    mariadb-10.1.32-1.fc26 \
    mod_wsgi-4.5.13-3.fc26 \
    net-tools-2.0-0.44.20160912git.fc26 \
    nmap-ncat-7.40-8.fc26 \
    preludedb-mysql-3.1.0-2.fc26 \
    prewikka-3.1.0-2.fc26 \
    procps-ng-3.3.10-13.fc26 \
    wget-1.19.4-1.fc26 \
  && dnf clean all \
	&& rm -rf /var/cache/dnf

COPY httpd-config/prewikka.conf /etc/httpd/conf.d/prewikka.conf
COPY prewikka-config/prewikka.conf /etc/prewikka/prewikka.conf

ENV INIT_SCRIPT_PATH /opt/start-prewikka.sh
COPY start-prewikka.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

RUN groupadd prelude \
  && useradd --create-home --system prewikka -g prelude

EXPOSE 80

ENTRYPOINT ["/opt/start-prewikka.sh"]
