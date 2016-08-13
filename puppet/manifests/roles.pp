import 'ssh.pp'
import 'swap.pp'

class role_common (
  $timezone,
) {
  include ssh

  if (!$::is_vagrant) {
    include swap
  }

  include '::ntp'

  class { 'timezone':
    timezone => $timezone,
  }

  # users in this group can sudo
  group { 'admin':
    ensure => present
  }
}

class roles::uber_server () inherits role_common {
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => 'localhost',
    manage_firewall            => true,
  }

  include sysctl
  include nginx
  include uber

  include uber::profile_rams_full_stack
  sysctl { 'fs.file-max': value => '200000' }
}

# debug only: use this to print all facts given to this node
#file { "/tmp/facts.yaml":
#  content => inline_template("<%= scope.to_hash.reject { |k,v| !( k.is_a?(String) && v.is_a?(String) ) }.to_yaml %>"),
#}
