import 'firewall.pp'
import 'ssh.pp'

class uber_server {
  include firewall_webserver
  include firewall_sshserver

  include ssh

  package { 'postgresql':
    ensure => present,
  }
  package { 'postgresql-contrib':
    ensure => present,
  }
  package { 'libpq-dev':
    ensure => present,
  }

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => 'localhost',
    manage_firewall            => true,
    require                   => [
      Package['postgresql'],
      Package['postgresql-contrib'],
      Package['libpq-dev'],
    ],
  }

  # users in this group can sudo
  group { 'admin':
    ensure => present
  }

  # users in this group can edit app files
  group { 'apps':
    ensure => present
  }

  # TODO: move this to uber module
  user { 'uber':
    ensure     => 'present',
    groups     => ['apps'],
    home       => '/home/uber',
    managehome => true,
    password   => '$876328756873465876345', # JUNK # '$6$lY2Gp3Cr$zNrUB7T3yibUF/gWn5cTQ0fNv7MUmx/DZuw3E7I..Vh9tITG28BtgvXJPU4Gm4Z/9oNvlbX24KzQ9Ib1QH1B9.', # hash for test. TODO: change
    shell      => '/bin/bash',
  }

}
