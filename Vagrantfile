# SPA prod machine

Vagrant.configure("2") do |config|
  # Main settings
  config.vm.box = "centos/7"
  config.vm.hostname = "spa"
  config.vm.boot_timeout = 1200

  # Network settings
  config.vm.network "forwarded_port", guest: 80, host: 4224, protocol: "tcp"

  # Ansible Provision
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "scripts/spa.yml"
  end

end
