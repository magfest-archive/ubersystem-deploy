/*
import 'ssh.pp'

class uber_server {

  include '::ntp'

  class { 'timezone':
    timezone => 'America/New_York',
  }

  include ssh
  include uber

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => 'localhost',
    manage_firewall            => true,
  }

  class { 'nginx': }

  # users in this group can sudo
  group { 'admin':
    ensure => present
  }
}
*/