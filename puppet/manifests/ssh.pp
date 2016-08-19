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
}
