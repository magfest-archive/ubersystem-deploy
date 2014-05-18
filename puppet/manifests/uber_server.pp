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
}
