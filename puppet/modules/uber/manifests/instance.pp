define uber::instance
(
  $uber_path = '/usr/local/uber',
  $git_repo = 'https://github.com/EliAndrewC/magfest',
  $git_branch = 'master',
  $uber_user = 'uber',
  $uber_group = 'apps',

  $db_host = 'localhost',
  $db_user = 'm13',
  $db_pass = 'm13',
  $db_name = 'm13',

  $socket_port = '4321',
  $socket_host = '0.0.0.0',
  $hostname = '', # defaults to hostname of the box
  $url_prefix = 'magfest',
) {

  $hostname_to_use = $hostname ? {
    ''      => $fqdn,
    default => $hostname,
  }

  $venv_path = "${uber_path}/env"
  $venv_bin = "${venv_path}/bin"
  $venv_python = "${venv_bin}/python"

  # TODO: don't hardcode 'python 3.4' in here, set it up in ::uber
  $venv_site_pkgs_path = "${venv_path}/lib/python3.4/site-packages"

  uber::user_group { "users and groups ${name}":
    user   => $uber_user,
    group  => $uber_group,
    before => Uber::Db["stop_daemon_${name}"],
  }

  uber::db { "ubersystem database ${name}":
    user       => $db_user,
    pass       => $db_pass,
    dbname     => $db_name,
    subscribe => Exec["uber_init_db_${name}"]
  }

  # Uber::Instance[$name] -> Class['uber::install']

  exec { "stop_daemon_${name}" :
    command     => "/usr/local/bin/supervisorctl stop ${name}",
    notify   => [ Class['uber::install'],
                  Vcsrepo[$uber_path], 
                  Uber::Daemon["${name}_daemon_start"] ]
  }

  vcsrepo { $uber_path:
    ensure   => latest,
    owner    => $uber_user,
    group    => $uber_group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch,
    notify   => File["${uber_path}/production.conf"],
  }

  file { "${uber_path}/production.conf":
    ensure  => present,
    mode    => 660,
    content => template('uber/production.conf.erb'),
    notify  => Exec["uber_virtualenv_${name}"]
  }

  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { "uber_virtualenv_${name}":
    command => "${uber::python_cmd} -m venv ${venv_path} --without-pip",
    cwd     => $uber_path,
    path    => '/usr/bin',
    creates => "${venv_path}",
    notify  => Exec["uber_distribute_setup_${name}"],
  }

  exec { "uber_distribute_setup_${name}" :
    command => "${venv_python} distribute_setup.py",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/setuptools.pth",
    notify  => Exec["uber_setup_${name}"],
  }

  exec { "uber_setup_${name}" :
    command => "${venv_python} setup.py develop",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/uber.egg-link",
    notify  => Exec["uber_init_db_${name}"],
  }

  # note: init_db.py will only init the DB if it doesn't already exist
  # i.e. there's no chance we'll clobber production data accidentally.
  exec { "uber_init_db_${name}" :
    command     => "${venv_python} uber/init_db.py",
    cwd         => "${uber_path}",
    refreshonly => true,
    notify      => Uber::Daemon["${name}_daemon_start"],
  }

  # run as a daemon with supervisor
  uber::daemon { "${name}_daemon_start" : 
    user         => $uber_user,
    group        => $uber_group,
    python_cmd   => $venv_python,
    uber_path    => $uber_path,
    subscribe    => Exec["uber_init_db_${name}"],
  }
}
