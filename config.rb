require "./vm.rb"

class MySQL < Vm
  Shortname  = "mysql"             # Vagrant name (used for manifest name, e.g., hm.pp)
  Longname   = "Drupal 7.x MySQL"     # VirtualBox name
  Host_IP    = "192.168.14.30"
  Memory     = "512"
  Cpus       = 4
end

