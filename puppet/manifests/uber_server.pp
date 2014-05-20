import 'firewall.pp'
import 'ssh.pp'

class uber_server {
  include firewall_webserver
  include firewall_sshserver
  include ssh
  include uber

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => 'localhost',
    manage_firewall            => true,
  }

  # users in this group can sudo
  group { 'admin':
    ensure => present
  }

  # look up info for what ubersystems we should create (if any)
  # in our hiera/nodes/{hostname}.yaml file
  $ubersystem_instances = hiera('uber_instances', {})
  create_resources('uber::instance', $ubersystem_instances)
}
