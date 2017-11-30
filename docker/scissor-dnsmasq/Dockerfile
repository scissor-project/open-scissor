FROM ferrarimarco/pxe:1.2.1

LABEL maintainer "ferrari.marco@gmail.com"

COPY etc/ /etc/

RUN \
  chmod -R 0664 /etc/dhcp-hosts \
  && chmod 0664 /etc/dnsmasq_static_hosts.conf \
  && chmod 0664 /etc/dnsmasq.conf

# Stop the dnsmasq service that is automatically started after installing the
# corresponding package and start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["sh", "-c", "service dnsmasq stop ; dnsmasq --no-daemon"]
