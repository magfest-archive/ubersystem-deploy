# Type: supervisor::program
#
# Usage: 
#
# supervisor::program { 'long-running-command':
#   command        => '/path/to/command',
#   directory      => '/tmp',
#   user           => 'some-user',
#   environment    => 'LIB=/path/to/lib,SOME_ENV=another_value',
#   stdout_logfile => '/path/to/stdout.log',
#   stderr_logfile => '/path/to/stderr.log',
# }
#
define supervisor::program (
  $command,
  $ensure                   = present,
  $enable                   = true,
  $numprocs                 = 1,
  $numprocs_start           = 0,
  $priority                 = 999,
  $autorestart              = 'unexpected',
  $startsecs                = 1,
  $retries                  = 3,
  $exitcodes                = '0,2',
  $stopsignal               = 'TERM',
  $stopwait                 = 10,
  $user                     = 'root',
  $group                    = 'root',
  $redirect_stderr          = false,
  $directory                = undef,
  $logdir_mode              = '0750',
  $stdout_logfile           = undef,
  $stdout_logfile_maxsize   = '250MB',
  $stdout_logfile_backups   = 10,
  $stderr_logfile           = undef,
  $stderr_logfile_maxsize   = '250MB',
  $stderr_logfile_backups   = 10,
  $environment              = undef,
  $umask                    = undef
) {
  if ! defined(Class['supervisor']) { include supervisor }

  case $ensure {
    absent: {
      $autostart = false
      $dir_recurse = true
      $dir_ensure = 'absent'
      $dir_force = true
      $service_ensure = 'stopped'
    }
    present: {
      $autostart = true
      $dir_ensure = 'directory'
      $dir_recurse = false
      $dir_force = false
      $service_ensure = 'running'

      if $enable == true {
        $config_ensure = undef
      } else {
        $config_ensure = absent
      }
    }
    default: {
      fail("ensure must be 'present' or 'absent', not ${ensure}")
    }
  }

  if $numprocs > 1 {
    $process_name = "${name}:*"
  } else {
    $process_name = $name
  }

  file { "/var/log/supervisor/${name}":
    ensure  => $dir_ensure,
    owner   => $user,
    group   => $group,
    mode    => $logdir_mode, # '0750',
    recurse => $dir_recurse,
    force   => $dir_force,
    require => Class['supervisor'],
  }

  file { "/etc/supervisord.d/${name}.conf":
    ensure  => $config_ensure,
    content => template('supervisor/program.conf.erb'),
    require => File["/var/log/supervisor/${name}"],
    notify  => Exec['supervisor::update'],
  }

  # easy_install behaves differently in adding binary path
  case $::osfamily {
    redhat: {
      $path_bin = '/usr/bin'
    }
    debian: {
      $path_bin = '/usr/local/bin'
    }
    default: { fail("ERROR: ${::osfamily} based systems are not supported!") }
  }

  service { "supervisor::${name}":
    ensure   => $service_ensure,
    provider => base,
    restart  => "${path_bin}/supervisorctl restart ${process_name}",
    start    => "${path_bin}/supervisorctl start ${process_name}",
    status   => "${path_bin}/supervisorctl status | awk '/^${name}[: ]/{print \$2}' | grep '^RUNNING$'",
    stop     => "${path_bin}/supervisorctl stop ${process_name}",
    require  => File["/etc/supervisord.d/${name}.conf"],
  }

  if ! defined(Exec['supervisor::update']) {
    exec { 'supervisor::update':
      command     => "${path_bin}/supervisorctl update",
      logoutput   => on_failure,
      refreshonly => true,
      require     => Service['supervisord'],
    }
  }

}
