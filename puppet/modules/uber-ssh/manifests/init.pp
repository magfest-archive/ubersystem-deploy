class uber-ssh {
      include ssh::install, ssh::config, ssh::service
}

class ssh::install {
  package { "ssh":
        ensure => present,
  }
}

class ssh::config {
  file { "/etc/ssh/sshd_config":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 600,
    source => "puppet:///modules/uber-ssh/sshd_config",
    notify => Class["ssh::service"],
  }
}

class ssh::service {
  service { "ssh":
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
  }
}

Class["ssh::install"] -> Class["ssh::config"] -> Class["ssh::service"]
