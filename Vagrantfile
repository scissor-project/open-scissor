DOMAIN_SUFFIX = "scissor"
DOMAIN = "." + DOMAIN_SUFFIX
INTNET_NAME = DOMAIN_SUFFIX + ".network"
NETWORK_TYPE_DHCP = "dhcp"
NETWORK_TYPE_STATIC_IP = "static_ip"
SUBNET_MASK = "255.0.0.0"

scissor = {
  "kafka" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :ip => "10.10.1.55",
    :mac_address => "0800271F9D01",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "flume" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.54",
    :mac_address => "0800271F9D02",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "semantics" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.65",
    :mac_address => "0800271F9D03",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "logstash" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :ip => "10.10.1.53",
    :mac_address => "0800271F9D04",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "logstash24" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :ip => "10.10.1.59",
    :mac_address => "0800271F9D05",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "datasource24" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.51",
    :mac_address => "0800271F9D06",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "d-streamon-master" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :ip => "10.10.1.99",
    :mac_address => "0800271F9D07",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "d-streamon-slave" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :ip => "10.10.1.66",
    :mac_address => "0800271F9D08",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "prelude-manager-oss" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.60",
    :mac_address => "0800271F9D09",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "prelude-correlator-oss" => {
    :autostart => false,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.61",
    :mac_address => "0800271F9D10",
    :mem => 2048,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "prewikka-oss" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.62",
    :mac_address => "0800271F9D11",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "kafka-idmef-converter" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.63",
    :mac_address => "0800271F9D12",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
  },
  "kafka-prelude-connector" => {
    :autostart => false,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :ip => "10.10.1.64",
    :mac_address => "0800271F9D13",
    :mem => 1024,
    :net_auto_config => true,
    :net_type => NETWORK_TYPE_STATIC_IP,
    :show_gui => false,
    :subnet_mask => SUBNET_MASK,
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

      host.vm.hostname = hostname

      host.vm.provision "shell", path: "provisioning/" + hostname + "/pre-install.sh"
      host.vm.provision "shell", path: "provisioning/" + hostname + "/install-packages.sh"
      host.vm.provision "shell", path: "provisioning/" + hostname + "/post-install.sh"
      host.vm.provision "shell" do |s|
        s.path = "provisioning/" + hostname + "/deployment.sh"
        s.args = ["#{info[:ip]}"]
      end
      host.vm.provision "shell", path: "provisioning/" + hostname + "/reporting.sh"
    end
  end
end
