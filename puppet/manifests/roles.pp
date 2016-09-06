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
  class { 'limits':
    config => {
      '*' => {
        'nofile' => {
          soft => '50000',
          hard => '50000',
        },
      },
    },
    use_hiera => false,
  }
  
  sysctl { 'fs.file-max': value => '200000' }

  include uber
  include nginx

  include uber::profile_rams_full_stack
}

# debug only: use this to print all facts given to this node
#file { "/tmp/facts.yaml":
#  content => inline_template("<%= scope.to_hash.reject { |k,v| !( k.is_a?(String) && v.is_a?(String) ) }.to_yaml %>"),
#}
