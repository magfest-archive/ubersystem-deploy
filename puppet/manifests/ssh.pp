class ssh {
  package { 'ssh':
    ensure => present,
  }

  file { '/etc/ssh/sshd_config':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 600,
    source => 'puppet:///modules/uber/sshd_config',
    notify => Service['ssh'],
  }

  service { 'ssh':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/etc/ssh/sshd_config'],
  }
  if defined(Class['ufw']) == false {
    include ufw
  }
  
  ufw::allow { 'allow-ssh-from-all':
    port => 22,
  }

  # (the IP is blocked if it initiates 6 or more connections within 30 seconds):
  ufw::limit { 22: }
}
