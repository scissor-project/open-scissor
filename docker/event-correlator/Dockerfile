FROM centos:centos7.4.1708

LABEL maintainer "ferrari.marco@gmail.com"

ENV P12FILE "/root/assystem-prelude.p12"
ENV P12FILE_RAW "/root/assystem-prelude.raw"
ENV PRIVATE_KEY "/root/assystem-prelude.priv.pem"
ENV PUBLIC_KEY "/root/assystem-prelude.pub.pem"
ENV PASSWORD "48c9AyFfU8"
ENV PRELUDE_GPG_KEY "/root/RPM-GPG-KEY-Prelude-IDS"

COPY keys/assystem-prelude.raw /root/assystem-prelude.raw

RUN base64 -d "$P12FILE_RAW" > "$P12FILE"

RUN \
  yum check-update \
  ; yum install -y \
    openssl-1.0.2k-8.el7 \
  && yum clean all \
	&& rm -rf /var/cache/yum

RUN \
  openssl pkcs12 -in "$P12FILE" -clcerts -nodes -nocerts -passin pass:"$PASSWORD" | openssl rsa > "$PRIVATE_KEY" \
  && openssl pkcs12 -in "$P12FILE" -clcerts -nokeys -passin pass:"$PASSWORD" | openssl x509 > "$PUBLIC_KEY"

COPY yum-config/release.prelude-siem.com_assystem_pkgs_centos_7_.repo /etc/yum.repos.d/release.prelude-siem.com_assystem_pkgs_centos_7_.repo
COPY keys/RPM-GPG-KEY-Prelude-IDS /root/RPM-GPG-KEY-Prelude-IDS

RUN rpm --import "$PRELUDE_GPG_KEY"

COPY yum-config/epel.repo /etc/yum.repos.d/epel.repo
COPY yum-config/scissor.repo /etc/yum.repos.d/scissor.repo

RUN \
  yum check-update \
  ; yum install -y epel-release-7-9 \
  && yum install -y \
    git-1.8.3.1-12.el7_4 \
    hostname-3.13-3.el7 \
    iproute-3.10.0-87.el7 \
    libprelude-devel-3.1.0-1.el7 \
    net-tools-2.0-0.22.20131004git.el7 \
    nmap-ncat-6.40-7.el7 \
    prelude-tools-3.1.0-1.el7 \
    procps-ng-3.3.10-16.el7 \
    python-libprelude-3.1.0-1.el7 \
	python2-pip-8.1.2-5.el7 \
    python-setuptools-0.9.8-7.el7 \
    wget-1.14-15.el7_4.1 \
  && yum clean all \
	&& rm -rf /var/cache/yum

ENV SCISSOR_LOG_DIR /var/log/scissor
RUN mkdir -p "$SCISSOR_LOG_DIR"

ENV INIT_SCRIPT_PATH /opt/start-event-correlator.sh
COPY start-event-correlator.sh $INIT_SCRIPT_PATH
RUN chmod a+x "$INIT_SCRIPT_PATH"

COPY prelude-config/client.conf /etc/prelude/default/client.conf

WORKDIR /opt
RUN git clone https://github.com/scissor-project/prelude-correlator.git

WORKDIR /opt/prelude-correlator
RUN pip install setuptools==39.0.1 --upgrade
RUN python setup.py install

ENV PRELUDE_PROFILE prelude-correlator

RUN useradd prelude-correlator -g prelude

ENTRYPOINT ["/opt/start-event-correlator.sh"]
