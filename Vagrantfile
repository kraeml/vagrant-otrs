# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # config.vm.box = 'hashicorp/precise32'
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 80, host: 3002, protocol: "tcp"
  config.vm.network "private_network", type: "dhcp"
  config.vm.host_name = "local-otrs-vm"

  config.vm.provision "shell",
    path: "bootstrap.sh"

  config.vm.provision "file",
    source: "Config.pm",
    destination: "Config.pm"

  config.vm.provision "shell",
    path: "db.sh"

  config.vm.provider "virtualbox" do |v|
    # Use VBoxManage to customize the VM. For example to change memory:
    v.customize ["modifyvm", :id, "--memory",               "1024"]
  end

end
