# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# Configure
MASTER_CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "vagrant-config/master/cloud-config.yml")
SLAVE_CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "vagrant-config/slave/cloud-config.yml")

# Defaults for config options defined
$master_vm_memory = 512
$slave_vm_memory = 256
$update_channel = "beta"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_cpus = 2
$shared_folders = {}
$forwarded_ports = {}

# Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def master_vm_memory
  $vb_memory.nil? ? $master_vm_memory : $vb_memory
end

def slave_vm_memory
  $vb_memory.nil? ? $slave_vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  config.vm.box = "coreos-%s" % $update_channel
  config.vm.box_version = ">= 308.0.1"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel

  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    config.vm.provider vmware do |v, override|
      override.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json" % $update_channel
    end
  end

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  # Master vagrant config
  config.vm.define master_vm_name = "master" do |master|
    master.vm.hostname = master_vm_name

    if $enable_serial_logging
      logdir = File.join(File.dirname(__FILE__), "log")
      FileUtils.mkdir_p(logdir)

      serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
      FileUtils.touch(serialFile)

      ["vmware_fusion", "vmware_workstation"].each do |vmware|
        master.vm.provider vmware do |v, override|
          v.vmx["serial0.present"] = "TRUE"
          v.vmx["serial0.fileType"] = "file"
          v.vmx["serial0.fileName"] = serialFile
          v.vmx["serial0.tryNoRxLoss"] = "FALSE"
        end
      end

      master.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
      end
    end

    ip = "10.0.3.10"
    master.vm.network :private_network, ip: ip, virtualbox__intnet: "host_net"

    ["vmware_fusion", "vmware_workstation"].each do |vmware|
      master.vm.provider vmware do |v|
        v.gui = vm_gui
        v.vmx['memsize'] = master_vm_memory
        v.vmx['numvcpus'] = vm_cpus
      end
    end

    master.vm.provider :virtualbox do |vb|
      vb.gui = vm_gui
      vb.memory = master_vm_memory
      vb.cpus = vm_cpus
    end

    # config.vm.provider :virtualbox do |vb|
    #   master_disk_name = "/tmp/master.vdi"
    #   if not File.exist?(master_disk_name) then
    #     vb.customize ['createhd', '--filename', master_disk_name, '--size', 100 * 1024]
    #   end
    #   vb.customize [
    #                   'storageattach', :id,
    #                   '--storagectl', 'IDE Controller',
    #                   '--port', 1,
    #                   '--device', 0,
    #                   '--type', 'hdd',
    #                   '--setuuid', "0b000000-b8cf-457e-9df4-e3f3f26d1e11",
    #                   '--medium', master_disk_name
    #                ]
    # end

    # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
    #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    $shared_folders.each_with_index do |(host_folder, guest_folder), index|
      master.vm.synced_folder host_folder.to_s, guest_folder.to_s, id: "core-share%02d" % index, nfs: true, mount_options: ['nolock,vers=3,udp']
    end

    if $share_home
      master.vm.synced_folder ENV['HOME'], ENV['HOME'], id: "home", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    end

    if File.exist?(MASTER_CLOUD_CONFIG_PATH)
      master.vm.provision :file, :source => "#{MASTER_CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
      master.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/vagrantfile-user-data", :privileged => true
    end
  end

  # Slave vagrant config
  config.vm.define slave_vm_name = "slave" do |slave|
    slave.vm.hostname = slave_vm_name

    if $enable_serial_logging
      logdir = File.join(File.dirname(__FILE__), "log")
      FileUtils.mkdir_p(logdir)

      serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
      FileUtils.touch(serialFile)

      ["vmware_fusion", "vmware_workstation"].each do |vmware|
        slave.vm.provider vmware do |v, override|
          v.vmx["serial0.present"] = "TRUE"
          v.vmx["serial0.fileType"] = "file"
          v.vmx["serial0.fileName"] = serialFile
          v.vmx["serial0.tryNoRxLoss"] = "FALSE"
        end
      end

      slave.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
      end
    end

    ip = "10.0.3.20"
    slave.vm.network :private_network, ip: ip, virtualbox__intnet: "host_net"

    ["vmware_fusion", "vmware_workstation"].each do |vmware|
      slave.vm.provider vmware do |v|
        v.gui = vm_gui
        v.vmx['memsize'] = slave_vm_memory
        v.vmx['numvcpus'] = vm_cpus
      end
    end

    slave.vm.provider :virtualbox do |vb|
      vb.gui = vm_gui
      vb.memory = slave_vm_memory
      vb.cpus = vm_cpus
    end

    slave.vm.provider :virtualbox do |vb|
      slave_disk_name = "/tmp/slave.vdi"
      if not File.exist?(slave_disk_name) then
        vb.customize ['createhd', '--filename', slave_disk_name, '--size', 100 * 1024]
      end
      vb.customize [
                      'storageattach', :id,
                      '--storagectl', 'IDE Controller',
                      '--port', 1,
                      '--device', 0,
                      '--type', 'hdd',
                      '--setuuid', "1b000000-b8cf-457e-9df4-e3f3f26d1e11",
                      '--medium', slave_disk_name
                   ]
    end

    # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
    #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    $shared_folders.each_with_index do |(host_folder, guest_folder), index|
      slave.vm.synced_folder host_folder.to_s, guest_folder.to_s, id: "core-share%02d" % index, nfs: true, mount_options: ['nolock,vers=3,udp']
    end

    if $share_home
      slave.vm.synced_folder ENV['HOME'], ENV['HOME'], id: "home", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    end

    if File.exist?(SLAVE_CLOUD_CONFIG_PATH)
      slave.vm.provision :file, :source => "#{SLAVE_CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
      slave.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/vagrantfile-user-data", :privileged => true
    end
  end

end
