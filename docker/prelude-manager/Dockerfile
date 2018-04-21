FROM fedora:26

LABEL maintainer "ferrari.marco@gmail.com"

RUN \
  dnf check-update \
  ; dnf install -y \
    hostname-3.18-2.fc26 \
    iproute-4.11.0-1.fc26 \
    libpreludedb-3.1.0-2.fc26 \
    mariadb-10.1.32-2.fc26 \
    net-tools-2.0-0.44.20160912git.fc26 \
    nmap-ncat-7.40-8.fc26 \
    prelude-manager-3.1.0-2.fc26 \
    prelude-manager-db-plugin-3.1.0-2.fc26 \
    prelude-tools-3.1.0-30.fc26 \
    preludedb-mysql-3.1.0-2.fc26 \
    preludedb-tools-3.1.0-2.fc26 \
    procps-ng-3.3.10-13.fc26 \
    wget-1.19.4-1.fc26 \
  && dnf clean all \
	&& rm -rf /var/cache/dnf

COPY prelude/prelude-registrator.conf /etc/prelude/prelude-registrator.conf
COPY prelude-manager/prelude-manager.conf /etc/prelude-manager/prelude-manager.conf
COPY tmpfiles.d/prelude-manager.conf /usr/lib/tmpfiles.d/prelude-manager.conf

ENV INIT_SCRIPT_PATH /opt/start-prelude-manager.sh
COPY start-prelude-manager.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

EXPOSE 4690 5553

ENTRYPOINT ["/opt/start-prelude-manager.sh"]
