# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Taban kutu olarak standart Ubuntu 22.04 LTS kullanıyoruz
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "ykos"

  # Güvenlik için Host-Only özel ağ (Sadece ana makineden erişilebilir)
  config.vm.network "private_network", ip: "192.168.56.20"

  # VirtualBox donanım yapılandırması
  config.vm.provider "virtualbox" do |vb|
    vb.name = "YkOs-Vulnerable-Lab"
    vb.memory = "2048"
    vb.cpus = 2
  end

  # Otomatik provisioning scriptini çalıştır
  config.vm.provision "shell", path: "setup_ykos.sh"
end
