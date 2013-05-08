require "./vm.rb"

# Global configuration for the project goes here.
# All class constants in Conf will be exposed as Facts to Puppet, with the
# constant name changed to lowercase.
class Conf
  Project   = "rome"                     # Rename this to match the name of your project.
  Mvm       = true                       # Set to false to build a single über VM instead.
  Network   = "192.168"                  # Private network address: ###.###.0.0
  Subnet    = "100"                      # Private network address: ###.###.0.0
  Host_IP   = 10                         # Starting host address: 192.168.0.###
  Modules   = {'rome' => 'modules/'}     # hash of puppet module folder names
  #NFS_www   = '192.168.100.1:/Users/MYUSERNAME/vagrant/projects/rome/www' # Point this to your www directory for UDP NFS.
  #Apt_proxy = 'http://192.168.31.42:3142' # Use this URL as an apt proxy.
  SSH_range = (32200..32250)
  Facts     = {}                         # Hash of Facts. Add your own or just add class constants.
end

# VM configuration starts here.
class OneBox < Vm
  Shortname  = "onebox"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Mvm        = false                # Is this VM a part of the MVM configuration?
  Longname   = "Drupal 7.x"     # VirtualBox name
  Host_IP    = "10"
  Memory     = "2048"
  Cpus       = 4
  NFS_shares = {"www" => "/mnt/www"}
end

class MySQL < Vm
  Shortname  = "mysql"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Mvm        = true                # Is this VM a part of the MVM configuration?
  Longname   = "Drupal 7.x MySQL"     # VirtualBox name
  Host_IP    = "10"
  Memory     = "512"
  Cpus       = 4
end

class Memcache < Vm
  Shortname  = "memcache"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Mvm        = true                # Is this VM a part of the MVM configuration?
  Longname   = "Drupal 7.x Memcache"     # VirtualBox name
  Host_IP    = "20"
  Memory     = "192"
  Cpus       = 4
end

class Solr < Vm
  Shortname  = "solr"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Mvm        = true                # Is this VM a part of the MVM configuration?
  Longname   = "Drupal 7.x Solr"     # VirtualBox name
  Host_IP    = "30"
  Memory     = "256"
  Cpus       = 4
end

class Apache < Vm                   # VM-specific overrides of default settings
  Shortname  = "apache"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Mvm        = true                # Is this VM a part of the MVM configuration?
  Longname   = "Drupal 7.x Apache"     # VirtualBox name
  Host_IP    = "40"
  Memory     = "1024"
  Cpus       = 4
  NFS_shares = {"www" => "/mnt/www"}
end

