scissor = {
  "kafka" => {
    :autostart => true,
    :box => "boxcutter/ubuntu1604",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.55",
    :show_gui => false
  },
  "logstash" => {
    :autostart => true,
    :box => "boxcutter/ubuntu1604",
    :cpus => 1,
    :mem => 1024,
    :ip => "10.10.1.53",
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
