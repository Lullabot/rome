node "mysql" {
  include mysql::server

  # Keep track of our customized configuration files.
  #file { '/etc/mysql/my.cnf':
  #    ensure  => present,
  #    source  => '/vagrant/files/mysql/etc/mysql/my.cnf',
  #    owner   => 'root',
  #    group   => 'root',
  #}
}

node "memcache" {
  class { 'apt':
    always_apt_update => true,
  }

  class { 'memcached':
    mem => 96,
    listen => 'INADDR_ANY',
  }
}

