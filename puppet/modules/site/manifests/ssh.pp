class site::ssh {
  package { 'ssh':
    ensure => present,
  }

  file { '/etc/ssh/sshd_config':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 600,
    source => 'puppet:///modules/uber/sshd_config', # TODO: move to 'site' module
    notify => Service['ssh'],
  }

  service { 'ssh':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/etc/ssh/sshd_config'],
  }

  include ufw
  
  ufw::allow { 'allow-ssh-from-all':
    port => 22,
  }

  # (the IP is blocked if it initiates 6 or more connections within 30 seconds):
  ufw::limit { 22: }
}
