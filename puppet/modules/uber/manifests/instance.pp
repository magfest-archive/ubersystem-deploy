define uber::instance (
  $db_name     = 'm_uber',
  $db_pass     = 'm_uber',
  $db_user     = 'm_uber',
  $uber_path   = '/usr/local/uber',
  $git_repo    = 'https://github.com/EliAndrewC/magfest',
  $git_branch  = 'master',
  $url_prefix  = 'magfest',
  $socket_port = '4321',
  $uber_user = 'uber',
  $uber_group = 'apps',
  $service_name = 'uber',
)
{
  group { $uber_group:
    ensure => present
  }

  user { $uber_user:
    ensure     => 'present',
    groups     => [$uber_group],
    home       => "/home/${uber_user}",
    managehome => true,
    shell      => '/bin/bash',
  }

  uber::db { 'ubersystem database':
    user   => $db_user,
    pass   => $db_pass,
    dbname => $db_name,
  }

  uber::python { 'ubersystem setup':
    db_user      => $db_user,
    db_pass      => $db_pass,
    db_name      => $db_name,
    uber_path    => $uber_path,
    git_repo     => $git_repo,
    git_branch   => $git_branch,
    url_prefix   => $url_prefix,
    socket_port  => $socket_port,
    uber_user    => $uber_user,
    uber_group   => $uber_group,
    service_name => $service_name,
  }
}
