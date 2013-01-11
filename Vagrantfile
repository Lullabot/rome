Vagrant::Config.run do |config|
  require "./config.rb"

  Vm.descendands.each_with_index do |vm,count_vms|
    config.vm.define "#{vm::Shortname}#{index}" do |vm_config|
      vm_config.ssh.max_tries = vm::SSH_tries
      vm_config.ssh.forward_agent = vm::SSH_forward_agent
      vm_config.vm.box = vm::Basebox
      vm_config.vm.box_url = vm::Box_url
      vm_config.vm.auto_port_range = Conf::SSH_range
      
      # Allow VMs to define a static IP to assign. This helps with multi-vm
      # scenarios where we want to ensure that IPs to various boxes are
      # consistent across reboots.
      if defined?(vm::Host_IP)
        ip = vm::Host_IP
      else
        ip = "#{Conf::Network}.#{Conf::Subnet}.#{Conf::Host_IP + ((count_vms) * 10) + index - 1}"
      end

      vm_config.vm.network :hostonly, ip

      hostname = "#{vm::Shortname}#{count}.#{Conf::Project}.#{vm::Domain}"
      vm_config.vm.host_name = hostname
      vm_config.vm.customize ["modifyvm", :id, "--name", "#{vm::Longname}#{formatted_count}(#{hostname})"]
      vm_config.vm.customize ["modifyvm", :id, "--memory", "#{vm::Memory}"]
      vm_config.vm.customize ["modifyvm", :id, "--cpus", "#{vm::Cpus}"]
      if (vm::Cpus > 1)
        vm_config.vm.customize ["modifyvm", :id, "--ioapic", "on"]
      end

      # If the vbguest plugin is enabled, we disable auto_updates. Otherwise,
      # initial provisioning can fail as the vboxsf module can't be loaded
      # until the VM is rebooted.
      vm_config.vbguest.auto_update = false
      
      if vm::Gui == true
        vm_config.vm.boot_mode = :gui
      end

      if File::exists?("#{vm::Manifests}/#{vm::Site}.pp")
        vm_config.vm.provision :puppet do |puppet|
          puppet.manifest_file = "#{vm::Site}.pp"
          # Initialize an empty array so we can push onto it
          puppet.module_path = []
          # Merge in project-specific Puppet modules
          vm::Modules.update(Conf::Modules)
          vm::Modules.each do |name,path|
            # Expand relative paths (such as '~')
            full_path = File.expand_path("#{path}")
            # Cull directories that don't exist, since Puppet will
            # throw errors if passed a module_path that doesn't exist
            if File::directory?("#{full_path}")
              puppet.module_path.push("#{full_path}")
            end
          end
          puppet.facter = Conf::Facts.update(vm::Facts)
          puppet.options = vm::Options
          if vm::Debug == true
            puppet.options = puppet.options + " --debug"
          end
          if vm::Verbose == true
            puppet.options = puppet.options + " --verbose"
          end
        end
      end
    end
  end
end

