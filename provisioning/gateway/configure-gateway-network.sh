#!/bin/sh

interface="$(ls --ignore="lo" /sys/class/net/ | sed -n '2p')"
host_ip_address=$1
subnet_mask=$2

echo "Configuring $interface interface with static IP address"
common_network_config="\n\
auto $interface\n\
iface $interface inet static\n\
      address $host_ip_address\n\
      netmask $subnet_mask\n"

# We are configuring the gateway network interface
# so don't add the default route via the gateway itself, otherwise we lose
# internet connettivity.

# We need to configure IP forwarding and iptables
echo "Enable IPv4 forwarding"
sed -in '/ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

echo "Configuring iptables"
iptables --table nat --append POSTROUTING --out-interface enp0s3 -j MASQUERADE
# Add a line like this for each eth* LAN
iptables --append FORWARD --in-interface $interface -j ACCEPT

ip_v4_rules_path="/etc/iptables/rules.v4"
if [ ! -f "$ip_v4_rules_path" ]; then
  echo "Saving iptables rules"
  mkdir -p /etc/iptables
  iptables-save > $ip_v4_rules_path
fi


echo "Configuring post-up hook to restore iptables configuration for the gateway"
default_gateway_config="      pre-up sleep 5\n\
      post-up iptables-restore < $ip_v4_rules_path\n"

echo "Network configuration for $interface interface:$common_network_config $default_gateway_config"
grep -q -F "auto $interface" /etc/network/interfaces \
|| printf "$common_network_config\
$default_gateway_config" >> /etc/network/interfaces

echo "/etc/network/interfaces contents:\n$(cat /etc/network/interfaces)"

echo "Restarting the networking service"
systemctl restart networking.service
