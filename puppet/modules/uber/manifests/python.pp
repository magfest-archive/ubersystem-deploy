# TODO: probably rename this file from python to ubersystem
# or, move the ubersystem-specific stuff out of here.

# TODO: hostname as a paramater

# TODO: dependency chain in here is slightly busted.


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

  $service_name = 'uber',
) {

  # TODO: move to its own file
  #include supervisor
  define uber_daemon (
    $user = 'uber',
    $group = 'uber',
    $ensure = present,
    $python_cmd = undef,
    $uber_path = undef,
    $service_name = undef
  ) {
    supervisor::program { $service_name :
      ensure        => $ensure,
      enable        => true,
      command       => "${python_cmd} uber/run_server.py",
      directory     => $uber_path,
      # environment => 'NODE_ENV=testing',
      user          => $user,
      group         => $group,
      logdir_mode   => '0770',
    }
  }


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

  /*exec { "stop_${service_name}" :
    command     => "supervisorctl stop ${service_name}",
    cwd         => 
    refreshonly => true,
    subscribe   => Vcsrepo['$uber_path'],
  }*/

  class { '::python':
    # ensure   => present,
    version    => $python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
    notify     => Vcsrepo[$uber_path],
  }

  # TODO install UTF lcoale stuff from Eli's Vagrant script
  package { "git": ensure => present }

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
    notify      => Supervisor::Program[$service_name]
  }

  # run as a daemon with supervisor
  uber_daemon { "${service_name}_daemon_start" : 
    user         => $uber_user,
    group        => $uber_group,
    python_cmd   => $venv_python,
    uber_path    => $uber_path,
    service_name => $service_name,
    subscribe    => Exec['uber_init_db'],
  }

}
