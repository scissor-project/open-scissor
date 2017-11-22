require 'ipaddr'

CENTOS_BOX_ID = "bento/centos-7.4"
DOMAIN = "scissor-project.com"
GATEWAY_MACHINE_NAME = "gateway"
GATEWAY_IP_ADDRESS = "10.10.0.1"
INTNET_NAME = DOMAIN + ".network"
NETWORK_TYPE_DHCP = "dhcp"
NETWORK_TYPE_STATIC_IP = "static_ip"
UPSTREAM_DNS_SERVER = "8.8.8.8"
SUBNET_MASK = "255.0.0.0"
UBUNTU_BOX_ID = "bento/ubuntu-16.04"

# VM names
D_STREAMON_MASTER_VM_NAME = "d-streamon-master"
D_STREAMON_SLAVE_VM_NAME = "d-streamon-slave"
DATASOURCE24_VM_NAME = "datasource24"
FLUME_VM_NAME = "flume"
KAFKA_IDMEF_CONVERTER_VM_NAME = "kafka-idmef-converter"
KAFKA_PRELUDE_CONNECTOR_VM_NAME = "kafka-prelude-connector"
KAFKA_VM_NAME = "kafka"
LOGSTASH_VM_NAME = "logstash"
LOGSTASH_24_VM_NAME = "logstash24"
EVENT_CORRELATOR_VM_NAME = "event-correlator"
PRELUDE_MANAGER_VM_NAME = "prelude-manager-oss"
PREWIKKA_VM_NAME = "prewikka-oss"
SEMANTICS_VM_NAME = "semantics"

DNS_SERVER_IP_ADDRESS = GATEWAY_IP_ADDRESS
DNS_SERVER_MACHINE_NAME = GATEWAY_MACHINE_NAME
IP_V4_CIDR = IPAddr.new(SUBNET_MASK).to_i.to_s(2).count("1")

dhcp_ips = {}
# Get IP addresses from DNSmasq configuration
File.foreach('docker/scissor-dnsmasq/etc/dhcp-hosts/static-ip-leases.conf') {
  |x|
  ip_assignment_elements = x.split(",")
  dhcp_hostname = ip_assignment_elements[1]
  dhcp_ip = ip_assignment_elements[2]
  if(ip_assignment_elements.length > 1)
    dhcp_ips[dhcp_hostname] = dhcp_ip.gsub("\n", "")
  end
}

scissor = {
  GATEWAY_MACHINE_NAME => {
    :autostart => true,
    :box => UBUNTU_BOX_ID,
    :cpus => 1,
    :dns_server_address => DNS_SERVER_IP_ADDRESS,
    :ip => GATEWAY_IP_ADDRESS,
    :mac_address => "0800271F0001",
    :mem => 512,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK
  },
  KAFKA_VM_NAME => {
    :autostart => true,
    :box => UBUNTU_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D01",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  FLUME_VM_NAME => {
    :autostart => true,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D02",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  SEMANTICS_VM_NAME => {
    :autostart => true,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D03",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  LOGSTASH_VM_NAME => {
    :autostart => true,
    :box => UBUNTU_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D04",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  LOGSTASH_24_VM_NAME => {
    :autostart => true,
    :box => UBUNTU_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D05",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  DATASOURCE24_VM_NAME => {
    :autostart => true,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D06",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  D_STREAMON_MASTER_VM_NAME => {
    :autostart => true,
    :box => UBUNTU_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D07",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  D_STREAMON_SLAVE_VM_NAME => {
    :autostart => true,
    :box => UBUNTU_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D08",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  PRELUDE_MANAGER_VM_NAME => {
    :autostart => true,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D09",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  EVENT_CORRELATOR_VM_NAME => {
    :autostart => false,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D14",
    :mem => 2048,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  PREWIKKA_VM_NAME => {
    :autostart => true,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D11",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  KAFKA_IDMEF_CONVERTER_VM_NAME => {
    :autostart => true,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D12",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  },
  KAFKA_PRELUDE_CONNECTOR_VM_NAME => {
    :autostart => false,
    :box => CENTOS_BOX_ID,
    :cpus => 1,
    :mac_address => "0800271F9D13",
    :mem => 1024,
    :net_auto_config => false,
    :net_type => NETWORK_TYPE_DHCP,
    :show_gui => false
  }
}

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  scissor.each do |(hostname, info)|
    config.vm.define hostname, autostart: info[:autostart] do |host|
      host.vm.box = "#{info[:box]}"

      if(NETWORK_TYPE_DHCP == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], :mac => "#{info[:mac_address]}", type: info[:net_type], virtualbox__intnet: INTNET_NAME
      elsif(NETWORK_TYPE_STATIC_IP == info[:net_type])
        host.vm.network :private_network, auto_config: info[:net_auto_config], :mac => "#{info[:mac_address]}", ip: "#{info[:ip]}", :netmask => "#{info[:subnet_mask]}", virtualbox__intnet: INTNET_NAME
      end
      host.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", info[:cpus]]
        vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
        vb.customize ["modifyvm", :id, "--memory", info[:mem]]
        vb.customize ["modifyvm", :id, "--name", hostname]
        vb.gui = info[:show_gui]
        vb.name = hostname
      end
      host.vm.hostname = hostname + "." + DOMAIN

      # Let's use the upstream server in the machine that will host our DNS
      # server because we cannot start the Dnsmasq container (with the
      # integrated DNS server) if we don't first install Docker and run a
      # container running DNSMasq. The name resolution will be
      # reconfigured to use our DNS server after such server is available
      ip_v4_dns_server_address = (hostname.include? DNS_SERVER_MACHINE_NAME) ? UPSTREAM_DNS_SERVER : DNS_SERVER_IP_ADDRESS
      host.vm.provision "shell" do |s|
        s.path = "provisioning/networking/configure-name-resolution.sh"
        s.args = [
          "--ip-v4-dns-nameserver", ip_v4_dns_server_address
          ]
      end

      if(GATEWAY_IP_ADDRESS == "#{info[:ip]}")
        host.vm.provision "shell" do |s|
          s.path = "provisioning/" + hostname + "/configure-gateway-network.sh"
          s.args = ["#{info[:ip]}", "#{info[:dns_server_address]}", SUBNET_MASK, DOMAIN]
        end
      else
        host.vm.provision "shell" do |s|
          s.path = "provisioning/networking/configure-volatile-network-interface.sh"
          s.args = [
            "--ip-v4-host-address", "#{info[:ip]}",
            "--ip-v4-host-cidr", IP_V4_CIDR,
            "--network-type", "#{info[:net_type]}"
            ]
        end

        # Ensure we are temporarily going through the gateway
        host.vm.provision "shell" do |s|
          s.path = "provisioning/networking/configure-volatile-default-route.sh"
          s.args = [
            "--ip-v4-gateway-ip-address", GATEWAY_IP_ADDRESS
            ]
        end

        # Install NetworkManager on Ubuntu
        if (UBUNTU_BOX_ID == info[:box])
          host.vm.provision "shell", path: "provisioning/networking/install-network-manager.sh"
        end

        # Ensure we are going through the gateway
        host.vm.provision "shell" do |s|
          s.path = "provisioning/networking/configure-default-route.sh"
          s.args = [
            "--ip-v4-gateway-ip-address", GATEWAY_IP_ADDRESS
            ]
        end

        # Configure network interfaces with NetworkManager
        if(NETWORK_TYPE_STATIC_IP == "#{info[:net_type]}")
          host.vm.provision "shell" do |s|
            s.path = "provisioning/networking/configure-network-manager.sh"
            s.args = [
              "--domain", DOMAIN,
              "--ip-v4-dns-nameserver", ip_v4_dns_server_address,
              "--ip-v4-gateway-ip-address", GATEWAY_IP_ADDRESS,
              "--ip-v4-host-cidr", IP_V4_CIDR,
              "--ip-v4-host-address", "#{info[:ip]}",
              "--network-type", "#{info[:net_type]}"
            ]
          end
        elsif(NETWORK_TYPE_DHCP == "#{info[:net_type]}")
          host.vm.provision "shell" do |s|
            s.path = "provisioning/networking/configure-network-manager.sh"
            s.args = [
              "--network-type", "#{info[:net_type]}"
            ]
          end
        end
      end

      # Configure the DNS server
      if(DNS_SERVER_IP_ADDRESS == "#{info[:ip]}")
        host.vm.provision "shell", path: "provisioning/" + hostname + "/install-docker.sh"
        host.vm.provision "file", source: "docker/scissor-dnsmasq", destination: "/tmp/"
        host.vm.provision "shell", path: "provisioning/" + hostname + "/build-dnsmasq.sh"
        host.vm.provision "shell", path: "provisioning/" + hostname + "/start-dnsmasq.sh"

        # Reconfigure name resolution to use our DNS server
        host.vm.provision "shell" do |s|
          s.path = "provisioning/networking/configure-name-resolution.sh"
          s.args = [
            "--ip-v4-dns-nameserver", DNS_SERVER_IP_ADDRESS
            ]
        end
      end
      unless(DNS_SERVER_IP_ADDRESS == "#{info[:ip]}" || GATEWAY_IP_ADDRESS == "#{info[:ip]}")
        host.vm.provision "shell", path: "provisioning/" + hostname + "/pre-install.sh"
        host.vm.provision "shell", path: "provisioning/" + hostname + "/install-packages.sh"
        host.vm.provision "shell", path: "provisioning/" + hostname + "/post-install.sh"
        deployment_args = []
        if(hostname.include? KAFKA_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname
          ]
        elsif(hostname.include? FLUME_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[KAFKA_VM_NAME],
            dhcp_ips[SEMANTICS_VM_NAME]
          ]
        elsif(hostname.include? SEMANTICS_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[FLUME_VM_NAME]
          ]
        elsif(hostname.include? LOGSTASH_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[FLUME_VM_NAME],
            dhcp_ips[DATASOURCE24_VM_NAME],
            dhcp_ips[D_STREAMON_SLAVE_VM_NAME]
          ]
        elsif(hostname.include? LOGSTASH_24_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[FLUME_VM_NAME],
            dhcp_ips[DATASOURCE24_VM_NAME],
            dhcp_ips[D_STREAMON_SLAVE_VM_NAME]
          ]
        elsif(hostname.include? DATASOURCE24_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[LOGSTASH_24_VM_NAME],
            dhcp_ips[LOGSTASH_VM_NAME],
            dhcp_ips[KAFKA_VM_NAME]
          ]
        elsif(hostname.include? EVENT_CORRELATOR_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[PRELUDE_MANAGER_VM_NAME]
          ]
        elsif(hostname.include? PREWIKKA_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[PRELUDE_MANAGER_VM_NAME]
          ]
        elsif(hostname.include? KAFKA_IDMEF_CONVERTER_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[KAFKA_VM_NAME]
          ]
        elsif(hostname.include? KAFKA_PRELUDE_CONNECTOR_VM_NAME)
          deployment_args = [
            dhcp_ips[hostname],
            hostname,
            dhcp_ips[KAFKA_VM_NAME],
            dhcp_ips[PRELUDE_MANAGER_VM_NAME]
          ]
        end
        host.vm.provision "shell" do |s|
          s.path = "provisioning/" + hostname + "/deployment.sh"
          s.args = deployment_args
        end
      end
    end
  end
end
