#!/bin/sh

set -e

vagrant_interface="$(find /sys/class/net \( -not -name lo -and -not -name 'docker*' -and -not -type d \) -printf "%f\\n" | sort | sed -n '1p')"
interface="$(find /sys/class/net \( -not -name lo -and -not -name 'docker*' -and -not -type d \) -printf "%f\\n" | sort | sed -n '2p')"

echo "Configuring iptables to allow routing from $interface through $vagrant_interface (Vagrant managed) interface"

echo "Intalling iptables-persistent"
# Set values with debconf-set-selections to avoid questions during package installation
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get update
apt-get install -y iptables-persistent

# We need to configure IP forwarding and iptables
echo "Enabling IPv4 forwarding"
sed -i '/ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

echo "Configuring iptables"
iptables --table nat --append POSTROUTING --out-interface "$vagrant_interface" -j MASQUERADE
# Add a line like this for each eth* LAN
iptables --append FORWARD --in-interface "$interface" -j ACCEPT

echo "Saving iptables rules"
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
