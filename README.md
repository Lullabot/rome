Rome: A Multi-VM Vagrant Environment for LAMP developent
========================================================

Rome is a set of Vagrant and Puppet configurations used to create and manage a development environment where each service is hosted on a separate machine. This allows developers to accurately test productions scenarios where each environment is separated by a network of some kind.

Rome also defines a single VM ("OneBox") that is identical to the separate VM configuration, but builds a single VM instead. It can be useful for systems with low memory or disk space, while still coming close to modeling a production environment.

The following VM types are available within Rome:

* Apache
* MySQL
* Memcache
* Solr

Varnish is available as a VM type, but is not enabled in the default configuration.

Configuration
=============

It is recommended to use Rome as a full git clone with a local branch keeping track of changes.

    git clone <url>
    git checkout -b local
    vim config.rb
    vim manifests/nodes.pp
    git commit -m 'A useful commit message.'
    ./vagrant-init.sh
    vagrant vbguest # If you have https://github.com/dotless-de/vagrant-vbguest installed.
    vim /etc/hosts # Add the IP of the Apache server.

Most VM configuration is handled through config.rb. Within this file, define each VM as a subclass of Vm. Each Shortname property is used to tell Vagrant what Puppet configs to apply to the machine.

By default, all VMs are configured to use 4 CPUs. If running on a machine with less cores or threads, modify the Cpus variable as needed.

Initial `vagrant up`
====================

These VMs use Puppet to manage configuration. Puppet is an "eventually consistent" system, where dependency resolution might take several "vagrant provision" runs to complete configuration. For new VMs, this is especially an issue with installing new packages, as there's no simple way to ensure "apt-get update" runs before installing new packages. Use the included `vagrant-init.sh` script to work around this issue.

VM IPs
======

Rather than include a system to dynamically manage hostnames and IP addresses, Rome uses static IPs defined in the configuration files for each VM. By default, VMs are assigned IPs in the 192.168.100.0/255.255.255.0 subnet. Each VM uses a copy of files/common/etc/hosts to reference other machines.

NFS mounts
==========

Vagrant does not currently support mounting NFS shares with UDP. UDP is *much* faster than TCP for loading directory structures and many small files. For example, UDP mounting cut a Drupal site installation time in half. Since Vagrant doesn't support UDP mounting, we manage shared folders with Puppet. However, it's still nice to use Vagrant's automatic management of <code>/etc/exports</code>. Our workaround is to still share our folders, but to mount them in the VMs in alternate directories.

By default, a "www" folder within the Rome directory is mounted with NFS, over TCP, to `/mnt/www`. Edit manifests/node.pp, and edit the Puppet configuration to match your local system and mount it again in `/var/www`. This is probably an area for future improvement.

Credits
=======

Many ideas for this project came from [Drush Vagrant](https://drupal.org/project/drush-vagrant). Thanks to [ergonlogic](https://drupal.org/user/368613) for discussing ideas for how to approach Vagrant configuration and sharing his work with the Drupal community.

