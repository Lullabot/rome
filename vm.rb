class Vm
  def self.descendants
    ObjectSpace.each_object(::Class).select {|klass| klass < self }
  end

  Count      = 1
  Basebox    = "precise32"
  Box_url    = "http://files.vagrantup.com/precise32.box"
  Memory     = "256"
  Cpus       = 1
  Domain    = "local"                    # default domain
  Manifests = "manifests"                # puppet manifests folder name
  Modules   = {}                         # hash of puppet module folder names
  Site      = "site"                     # name of manifest to apply
  Gui       = false                      # start VM with GUI?
  Verbose   = false                      # make output verbose?
  Debug     = false                      # output debug info?
  Options   = ""                         # options to pass to Puppet
  Facts     = {}                         # hash of Factor facts
  SSH_tries = 5                          # How quickly to fail should Vagrant hang
  SSH_forward_agent = false              # Whether to forward SSH agent
end

class Global
  Network   = "192.168"                  # Private network address: ###.###.0.0
  Host_IP   = 10                         # Starting host address: 192.168.0.###
  SSH_range = (32200..32250)
end

