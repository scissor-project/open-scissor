scissor = {
  "kafka" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.55",
    :show_gui => false
  },
  "logstash" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.53",
    :show_gui => false
  },
  "datasource24" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.51",
    :show_gui => false
  },
  "flume" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.54",
    :show_gui => false
  },
  "logstash24" => {
    :autostart => true,
    :box => "bento/ubuntu-16.04",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.59",
    :show_gui => false
  },
  "semantics" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.65",
    :show_gui => false
  },
  "prelude-manager-oss" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.60",
    :show_gui => false
  },
  "prelude-correlator-oss" => {
    :autostart => false,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :mem => 2048,
    :ip => "10.10.1.61",
    :show_gui => false
  },
  "prewikka-oss" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.62",
    :show_gui => false
  },
  "kafka-idmef-converter" => {
    :autostart => true,
    :box => "bento/centos-7.4",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.63",
    :show_gui => false
  }
}

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  scissor.each do |(hostname, info)|
    config.vm.define hostname, autostart: info[:autostart] do |host|
      host.vm.box = "#{info[:box]}"

      config.vm.network :private_network, ip: "#{info[:ip]}"

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
