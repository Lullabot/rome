node "memcache" {
  class { 'apt':
    always_apt_update => true,
  }

  class { 'memcached':
    mem => 96,
    listen => 'INADDR_ANY',
  }
}

