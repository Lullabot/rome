require "./vm.rb"

# Global configuration for the project goes here.
class Conf
  Project   = "juno"                     # Rename this to match the name of your project.
  Network   = "192.168"                  # Private network address: ###.###.0.0
  Subnet    = "100"                      # Private network address: ###.###.0.0
  Host_IP   = 10                         # Starting host address: 192.168.0.###
  Modules   = {'rome' => 'modules/'}     # hash of puppet module folder names
  Facts     = {}                         # hash of Factor facts
  SSH_range = (32200..32250)
end

# VM configuration starts here.
class MySQL < Vm
  Shortname  = "mysql"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Longname   = "Drupal 7.x MySQL"     # VirtualBox name
  Host_IP    = "192.168.100.10"
  Memory     = "512"
  Cpus       = 4
end

class Memcache < Vm
  Shortname  = "memcache"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Longname   = "Drupal 7.x Memcache"     # VirtualBox name
  Host_IP    = "192.168.100.20"
  Memory     = "192"
  Cpus       = 4
end

class Solr < Vm
  Basebox    = "precise32"
  Box_url    = "http://files.vagrantup.com/precise32.box"
  Shortname  = "solr"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Longname   = "Drupal 7.x Solr"     # VirtualBox name
  Host_IP    = "192.168.100.30"
  Memory     = "256"
  Cpus       = 4
end

class Apache < Vm                   # VM-specific overrides of default settings
  Shortname  = "apache"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Longname   = "Drupal 7.x Apache"     # VirtualBox name
  Host_IP    = "192.168.100.40"
  Memory     = "1024"
  Cpus       = 4
  NFS_shares = {"www" => "/mnt/www"}
end

