stage { 'first':
    before => Stage['main'],
}

# Edit this class as needed to add additional hosts to your configuration.
class rome::mvmhosts {
  host { "mysql.${project}.local" :
    ip => $mysql_ip,
  }

  host { "memcache.${project}.local" :
    ip => $memcache_ip,
  }
  host { "solr.${project}.local" :
    ip => $solr_ip,
  }
  host { "apache.${project}.local" :
    ip => $apache_ip,
  }
}

class rome::onehost {
  host { "mysql.${project}.local" :
    ip => $onebox_ip,
  }

  host { "memcache.${project}.local" :
    ip => $onebox_ip,
  }
  host { "solr.${project}.local" :
    ip => $onebox_ip,
  }
  host { "apache.${project}.local" :
    ip => $onebox_ip,
  }
}

class apt-proxy {
  if $apt_proxy {
    file { "/etc/apt/apt.conf.d/71proxy":
      owner   => root,
      group   => root,
      mode    => '0644',
      content => "Acquire::http { Proxy \"${apt_proxy}\"; };",
    }
  }
  else {
    file { "/etc/apt/apt.conf.d/71proxy":
      ensure  => absent,
    }
  }

  file { 'etc apt confs':
    path => '/etc/apt/apt.conf.d',
    source => '/vagrant/files/common/etc/apt/apt.conf.d',
    recurse => true,
    owner => 'root',
    group => 'root',
  }
}

# VM configuration that should be included in all VMs.
class rome {
  include base

  Exec { path => "/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin" }

  class { 'apt-proxy':
    stage => first,
  }

  class { 'apt':
    always_apt_update => true,
    require => File[ "/etc/apt/apt.conf.d/71proxy" ],
    stage   => 'first',
  }

  package {'pbzip2':
    ensure => present,
  }

  package {'pigz':
    ensure => present,
  }

  package {'htop':
    ensure => present,
  }

  if $unattended_upgrades {
    package {'unattended-upgrades':
      ensure => present,
    }

    file { 'rc.local':
      path => '/etc/rc.local',
      source => '/vagrant/files/common/etc/rc.local',
      owner => 'root',
      group => 'root',
    }

    file { '/usr/local/bin/remove-old-kernels.sh':
      path => '/usr/local/bin/remove-old-kernels.sh',
      source => '/vagrant/files/common/usr/local/bin/remove-old-kernels.sh',
      owner => 'root',
      group => 'root',
    }
  }

  package {'vim':
    ensure => present,
  }

  package {'zerofree':
    ensure => present,
  }

}

class rome::apache inherits rome {
  include rome

  if $nfs_www {
    mount { "/var/www":
      device => $nfs_www,
      fstype => "nfs",
      ensure => "mounted",
      options => "udp",
      atboot => "false",
    }
  }

  class {'::php':}
  class {'::pear':}
  class {'::mysql::client':}

  class {'::apache':
    mod_php5 => true,
    mod_headers => true,
  }

  pear::package { "PEAR": }
  pear::package { "Console_Table": }

  pear::package { "drush":
    repository => "pear.drush.org",
    version => 'latest',
  }

  package { 'php5-xdebug':
      ensure => present,
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
  file { "/etc/apache2/sites-available/apache.${project}.local":
      ensure  => present,
      source  => '/vagrant/files/apache/etc/apache2/sites-available/default',
      owner   => 'root',
      group   => 'root',
  }

  file { "/etc/apache2/sites-enabled/apache.${project}.local":
      ensure  => 'link',
      target  => "/etc/apache2/sites-available/apache.${project}.local",
      notify  => Service['apache2'],
  }

  file { '/etc/php5/apache2/conf.d/custom.ini':
      ensure  => present,
      source  => '/vagrant/files/apache/etc/php5/apache2/conf.d/custom.ini',
      owner   => 'root',
      group   => 'root',
      notify  => Service['apache2'],
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

  # Create MySQL Database & User
  exec { "mysqladmin create ${project}":
      command => "mysqladmin CREATE ${project}",
      unless  => "mysql -e \"SHOW DATABASES LIKE '${project}'\" | grep ${project}",
  }

  exec { "mysql user ${project}":
      command => "mysql -e \"GRANT ALL ON \\`${project}\\`.* TO '${project}'@'${network}.${subnet}.%' IDENTIFIED BY '${project}'; FLUSH PRIVILEGES;\"",
      unless  => "mysql -e \"SHOW GRANTS FOR '${project}'@'${network}.${subnet}.%'\" | grep ${project}",
      require => Exec["mysqladmin create ${project}"],
  }
}

class rome::solr inherits rome {
  Exec {
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    logoutput => on_failure,
  }

  # Solr, and available indexes
  class { '::solr': }
  solr::index::drupal { "apache.${project}.local": version => '7.x-1.1' }

  # Automatically copy in our Solr configuration if it's been downloaded.
  exec { "copy solr configuration":
    command => "cp /var/lib/tomcat6/solr/apache.${project}.local/conf/solr-1.4/* /var/lib/tomcat6/solr/apache.${project}.local/conf",
    unless  => "grep drupal-3.0-0-solr1.4 /var/lib/tomcat6/solr/apache.${project}.local/conf/schema.xml",
    onlyif  => "test -f /var/lib/tomcat6/solr/apache.${project}.local/conf/solr-1.4/schema.xml",
    notify  => Service['tomcat6'],
  }
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
