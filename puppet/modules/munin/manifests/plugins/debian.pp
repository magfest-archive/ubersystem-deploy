# Debian specific plugins
class munin::plugins::debian  { 

  Package{ 'munin-node': }

  Service{ 'munin-node':
    ensure => running,
    enable => true,
    hasstatus  => false,
    hasrestart => true,
    provider => debian,
  }
}
