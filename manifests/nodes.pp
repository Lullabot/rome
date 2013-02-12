# Edit this class as needed to add additional hosts to your configuration.
class rome::mvmhosts {
  host { 'mysql.juno.local' :
    ip => '192.168.100.10',
  }

  host { 'memcache.juno.local' :
    ip => '192.168.100.20',
  }
  host { 'solr.juno.local' :
    ip => '192.168.100.30',
  }
  host { 'apache.juno.local' :
    ip => '192.168.100.40',
  }
}

class rome::onehost {
  host { 'mysql.juno.local' :
    ip => '127.0.0.1',
  }

  host { 'memcache.juno.local' :
    ip => '127.0.0.1',
  }
  host { 'solr.juno.local' :
    ip => '127.0.0.1',
  }
  host { 'apache.juno.local' :
    ip => '127.0.0.1',
  }
}

# VM configuration that should be included in all VMs.
class rome {
  include base
  class { 'apt':
    always_apt_update => true,
  }

  package {'unattended-upgrades':
    ensure => present,
  }

  file { 'etc apt confs':
    path => '/etc/apt/apt.conf.d',
    source => '/vagrant/files/common/etc/apt/apt.conf.d',
    recurse => true,
    owner => 'root',
    group => 'root',
  }
}

class rome::apache inherits rome {
  include rome
  include apache
  include php
  include pear
  include mysql::client

## Uncomment and edit this to match the path that you want to share to your VM.
#  mount { "/var/www":
#    device => "192.168.100.1:/Users/andrew/vagrant/projects/rome/www",
#    fstype => "nfs",
#    ensure => "mounted",
#    options => "udp",
#    atboot => "true",
#  }

  pear::package { "drush":
    repository => "pear.drush.org",
  }

  package { 'openjdk-7-jre-headless':
      ensure  => present,
  }

  file { [ '/usr/local/share/', '/usr/local/share/tika' ]:
      ensure => directory,
      owner   => 'root',
      group   => 'root',
  }

  # Download tika so we don't have to keep it in our git repository (it's 25M).
  download {
    "/usr/local/share/tika/tika-app-1.2.jar":
      uri => "http://www.apache.org/dyn/closer.cgi/tika/tika-app-1.2.jar",
      timeout => 900
  }

  # Keep track of our customized configuration files.
  file { '/etc/apache2/sites-available/default':
      ensure  => present,
      source  => '/vagrant/files/apache/etc/apache2/sites-available/default',
      owner   => 'root',
      group   => 'root',
  }

  file { '/etc/php5/apache2/php.ini':
      ensure  => present,
      source  => '/vagrant/files/apache/etc/php5/apache2/php.ini',
      owner   => 'root',
      group   => 'root',
  }

  file { '/etc/crontab':
      ensure => present,
      source => '/vagrant/files/apache/etc/crontab',
      owner   => 'root',
      group   => 'root',
  }
}

# Include this to add memcache to your VM.
class rome::memcache inherits rome {
  class { 'memcached':
    mem => 96,
    listen => "all",
  }
}

class rome::mysql inherits rome {
  include mysql::server

  # Keep track of our customized configuration files.
  file { '/etc/mysql/conf.d/local.cnf':
      ensure  => present,
      source  => '/vagrant/files/mysql/etc/mysql/conf.d/local.cnf',
      owner   => 'root',
      group   => 'root',
  }
}

class rome::solr inherits rome {
  Exec {
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    logoutput => on_failure,
  }

  # Solr, and available indexes
  class { '::solr': }
  solr::index::drupal { 'apache.juno.local': version => '7.x-1.1' }
}

node "onebox" {
  include rome::onehost
  include rome::apache
  include rome::memcache
  include rome::mysql
  include rome::solr
}

node "apache" {
  include rome::mvmhosts
  include rome::apache
}

node "memcache" {
  include rome::mvmhosts
  include rome::memcache
}

node "mysql" {
  include rome::mvmhosts
  include rome::mysql
}

node "solr" {
  include rome::mvmhosts
  include rome::solr
}

define download ($uri, $timeout = 300) {
    exec {
        "download $uri":
            command => "/usr/bin/wget -q '$uri' -O $name",
            creates => $name,
            timeout => $timeout,
            require => Package[ "wget" ],
    }
}
