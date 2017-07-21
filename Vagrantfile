# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.provision :saltdeps do |deps|
    deps.base_vagrantfile = "git@github.com:tyauvil/salt-vagrant-base.git"
    deps.checkout_path =  "./.vagrant-salt/deps"
  end
end
