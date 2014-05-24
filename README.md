# Vagrant ESXi Provider

This is a Vagrant plugin for VMware ESXi.

**NOTE:** This is a work in progress, it's based on [vagrant-vsphere](https://github.com/nsidc/vagrant-vsphere) and [vagrant-aws](https://github.com/mitchellh/vagrant-aws), the documentation below is supplementary.

## Usage

    gem build vagrant-esxi.gemspec
    vagrant plugin install ./vagrant-esxi-*.gem

## ESXi Host Setup

1. enable SSH
2. enable public key authentication, e.g. `cat ~/.ssh/id_rsa.pub | ssh root@host 'cat >> /etc/ssh/keys-root/authorized_keys'`
3. set the license key (if you haven't done so already), e.g. `ssh root@host vim-cmd vimsvc/license --set 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'`

## Example Vagrantfile

    config.vm.box = "precise64_vmware"
    config.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
    config.vm.hostname = "precise64"

    config.vm.provider :esxi do |esxi|
      esxi.name = "precise64"
      esxi.host = "host"
      esxi.datastore = "datastore1"
      esxi.user = "root"
      esxi.password = "Zkg1nJXM1sh19sw9uV6P"
    end

## Issues

https://github.com/pdericson/vagrant-esxi/issues
