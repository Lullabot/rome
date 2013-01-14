node "mysql" {
  include base
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
  include base
  class { 'apt':
    always_apt_update => true,
  }

  class { 'memcached':
    mem => 96,
    listen => 'INADDR_ANY',
  }
}

node "apache" {
  include base
  include apache
  include php
  include mysql::client

## Uncomment and edit this to match the path that you want to share to your VM.
#  mount { "/var/www":
#    device => "192.168.100.1:/Users/andrew/vagrant/projects/rome/www",
#    fstype => "nfs",
#    ensure => "mounted",
#    options => "udp",
#    atboot => "true",
#  }

  class { 'apt':
    always_apt_update => true,
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

node "solr" {
  include base
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

define download ($uri, $timeout = 300) {
    exec {
        "download $uri":
            command => "/usr/bin/wget -q '$uri' -O $name",
            creates => $name,
            timeout => $timeout,
            require => Package[ "wget" ],
    }
}
