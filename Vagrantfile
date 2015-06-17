# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
puppet module install --force stahnma-epel
puppet module install --force puppetlabs-stdlib
puppet module install --force puppetlabs-concat
puppet module install --force puppetlabs-apache
puppet module install --force saz-timezone
puppet module install --force treydock-gpg_key
puppet module install --force puppetlabs-nodejs
puppet module install --force ajcrowe-supervisord
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.box = "thinkside-vbox-centos-65-x64"
  config.vm.box_check_update = true

  config.vm.provider :virtualbox do |vb, override|
    override.vm.box_url = "http://vagrant.thinkside.eu/pcanham-centos65_64_virtualbox-puppet-3.7.2.box"
    vb.gui = true
    vb.customize [
      "modifyvm", :id,
      "--memory", "512",
      "--cpus", "4",
      "--natdnspassdomain1", "off",
    ]
  end

  config.vm.provider :vmware_fusion do |v, override|
    v.gui = true
    override.vm.box = "thinkside-vmware-centos-65-x64"
    override.vm.box_url = "http://vagrant.thinkside.eu/pcanham-centos65_64_vmware-puppet-3.7.2.box"
    v.vmx["memsize"] = 1024
    v.vmx["numvcpus"] = 4
  end

  config.vm.define :ghost do |ghost|
    ghost.vm.network "private_network", ip: "10.0.0.20"
    ghost.vm.hostname = "ghost"
    ghost.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048" ]
    end
    ghost.vm.provider :vmware_fusion do |v|
      v.vmx["memsize"] = 2048
    end
    ghost.vm.provision :shell, :inline => $script
    ghost.vm.provision :puppet,
      :options => ["--debug", "--verbose", "--summarize"],
      :facter => { "fqdn" => "ghost.sandbox.internal" } do |puppet|
        puppet.manifests_path = "./"
        puppet.manifest_file = "ghost.pp"
    end
  end
end
