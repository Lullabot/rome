node "mysql" {
  include mysql::server

  class { 'apt':
    always_apt_update => true,
  }

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

node "solr" {
  Exec {
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    logoutput => on_failure,
  }

  class { 'apt':
    always_apt_update => true,
  }

  # Solr, and available indexes
  class { 'solr': }
  solr::index::drupal { 'apache.juno.local': version => '7.x-1.1' }
}

