# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil
    if not Vagrant.has_plugin?('vagrant-proxyconf')
      system 'vagrant plugin install vagrant-proxyconf'
      raise 'vagrant-proxyconf was installed but it requires to execute again'
    end
    config.proxy.http     = ENV['http_proxy'] || ENV['HTTP_PROXY'] || ""
    config.proxy.https    = ENV['https_proxy'] || ENV['HTTPS_PROXY'] || ""
    config.proxy.no_proxy = ENV['no_proxy'] || ENV['NO_PROXY'] || ""
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"
  config.vm.hostname = "icn"

  config.vm.provider :libvirt do |libvirt|
    libvirt.graphics_ip = '0.0.0.0'
    libvirt.cpu_mode = 'host-model'
    libvirt.cpus = 32
    libvirt.cpuset = '0-21,44-65'
    libvirt.nested = true
    libvirt.memory = 40960
    libvirt.machine_virtual_size = 400
  end

  #
  # The DNS settings in generic/ubuntu1804 don't work behind the proxy
  # and the correct settings are required for apt to install the nfs
  # client libs.
  #
  # To see the synced_folder, first 'vagrant up' then 'vagrant
  # reload'.
  #
  if File.exist?(".vagrant/machines/default/libvirt/action_provision")
    config.vm.synced_folder ".", "/vagrant"
  else
    # Hold off on the sync
  end
  config.vm.provision "Fix networking", type: "shell", path: "fix-generic-ubuntu-dns.sh", privileged: true

  if File.exist?(".vagrant/machines/default/libvirt/action_provision")
    config.vm.provision "Installing requirements", type: "shell", privileged: true, inline: <<-SHELL
      source /etc/os-release || source /usr/lib/os-release
      case ${ID,,} in
          ubuntu|debian)
              apt-get update
              apt-get install -y -qq -o=Dpkg::Use-Pty=0 make
          ;;
      esac
    SHELL

    config.vm.provision "Adding hostname to no proxy", type: "shell", path: "add-hostname-to-no-proxy.sh", privileged: true

    config.vm.provision "Building ICN", type: "shell", privileged: true, inline: <<-SHELL
      cd /vagrant
      make verifier
    SHELL
  end
end

Vagrant.configure("2") do |config|
  #
  # Enable remote ssh access into the VM.
  #
  config.vm.network "forwarded_port", guest: 22, host: 2233
end
