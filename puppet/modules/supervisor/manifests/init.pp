# Class: supervisor
#
# Usage:
#   include supervisor
#
#   class { 'supervisor':
#     include_superlance      => false,
#     enable_http_inet_server => true,
#   }
#
#
# TODO: configurations pass as parameters
class supervisor (
  $include_superlance       = true,
  $enable_http_inet_server  = true,
) {

  case $::osfamily {
    redhat: {
      $pkg_setuptools = 'python-setuptools'
      $path_config    = '/etc'
      $path_bin       = '/usr/bin'
    }
    debian: {
      $pkg_setuptools = 'python-setuptools'
      $path_config    = '/etc'
      $path_bin       = '/usr/local/bin'
    }
    default: { fail("ERROR: ${::osfamily} based systems are not supported!") }
  }

  package { $pkg_setuptools: ensure => installed, }

  # let's stick with v3.0 for now
  exec { 'easy_install-supervisor':
    command => '/usr/bin/easy_install supervisor==3.0',
    creates => "${path_bin}/supervisord",
    user    => 'root',
    require => Package[$pkg_setuptools],
  }

  # install start/stop script
  file { '/etc/init.d/supervisord':
    source => "puppet:///modules/supervisor/${::osfamily}.supervisord",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/var/log/supervisor':
    ensure  => directory,
    purge   => true,
    backup => false,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => Exec['easy_install-supervisor'],
  }

  file { "${path_config}/supervisord.conf":
    ensure  => file,
    content => template('supervisor/supervisord.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec['easy_install-supervisor'],
    notify  => Service['supervisord'],
  }

  file { "${path_config}/supervisord.d":
    ensure => 'directory',
    owner => 'root',
    group => 'root',
    mode => '0755',
    require => File["${path_config}/supervisord.conf"],
  }

  service { 'supervisord':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File["${path_config}/supervisord.conf"],
  }

  if $include_superlance {
    exec { 'easy_install-superlance':
      command => '/usr/bin/easy_install superlance',
      creates => "${path_bin}/memmon",
      user    => 'root',
      require => Exec['easy_install-supervisor'],
    }
  }

}
