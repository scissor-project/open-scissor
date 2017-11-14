FROM ferrarimarco/pxe:1.2.1

LABEL maintainer "ferrari.marco@gmail.com"

# Stop the dnsmasq service that is automatically started after installing the
# corresponding package
RUN service dnsmasq stop

COPY etc/ /etc/

# Start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["dnsmasq", "--no-daemon"]
