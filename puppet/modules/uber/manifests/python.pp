# TODO: probably rename this file from python to ubersystem
# or, move the ubersystem-specific stuff out of here.

# TODO: dependency chain in here is maybe slightly busted.

class uber::python (
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
  $python_ver = '3'

  $hostname_to_use = $hostname ? {
    ''      => $fqdn,
    default => $hostname,
  }

  $python_cmd = $python_ver ? {
    '2'     => 'python2',
    '3'     => 'python3',
    default => fail("Bad python version: ${python_ver}"),
  }

  $venv_path = "${uber_path}/env"
  $venv_bin = "${venv_path}/bin"
  $venv_python = "${venv_bin}/python"

  # TODO: would be awesome to not have to hardcode this 'python 3.4' in there
  $venv_site_pkgs_path = "${venv_path}/lib/python3.4/site-packages"

  /*service { "supervisor::${name}" :
    ensure    => "stopped",
    subscribe => Vcsrepo['$uber_path'], # TODO: more/better stuff.
  }*/

  class { '::python':
    # ensure   => present,
    version    => $python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
    notify     => Exec["stop_${name}"],
  }

  # TODO install UTF lcoale stuff from Eli's Vagrant script
  package { "git": ensure => present }

  exec { "stop_${name}" :
    command     => "/usr/local/bin/supervisorctl stop ${name}",
    notify   => [ Vcsrepo[$uber_path], 
                  Uber::Daemon["${name}_daemon_start"] ]
  }

  vcsrepo { $uber_path:
    ensure   => latest,
    owner    => $uber_user,
    group    => $uber_group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch,
    require  => Package['git'],
    notify   => File['production.conf'],
  }

  file { 'production.conf':
    path    => "${uber_path}/production.conf",
    ensure  => present,
    mode    => 660,
    content => template('uber/production.conf.erb'),
    notify  => Exec['uber_virtualenv']
  }

  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { 'uber_virtualenv':
    command => "${python_cmd} -m venv ${venv_path} --without-pip",
    cwd     => $uber_path,
    path    => '/usr/bin',
    creates => "${venv_path}",
    notify  => Exec['uber_distribute_setup'],
  }

  exec { 'uber_distribute_setup' :
    command => "${venv_python} distribute_setup.py",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/setuptools.pth",
    notify  => Exec['uber_setup'],
  }

  exec { 'uber_setup' :
    command => "${venv_python} setup.py develop",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/uber.egg-link",
    notify  => Exec['uber_init_db'],
  }

  exec { 'uber_init_db' :
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
    subscribe    => Exec['uber_init_db'],
  }
}
