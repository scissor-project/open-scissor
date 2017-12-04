#!/bin/sh

set -e

vagrant_interface="$(find /sys/class/net \( -not -name lo -and -not -name 'docker*' -and -not -type d \) -printf "%f\\n" | sort | sed -n '1p')"
vagrant_network_configuration_file_path="/etc/sysconfig/network-scripts/ifcfg-$vagrant_interface"
echo "Disabling default route for Vagrant managed interface ($vagrant_interface)"
sed -i '/DEFROUTE/d' "$vagrant_network_configuration_file_path" && echo "DEFROUTE=\"no\"" >> "$vagrant_network_configuration_file_path"
echo "Restarting NetworkManager service to let it pick up configuration changes"
systemctl restart NetworkManager.service
sleep 5
echo "Current IP routes:
$(ip route)"
