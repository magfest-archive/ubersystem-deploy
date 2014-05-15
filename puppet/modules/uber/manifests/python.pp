# TODO: add in database user/password/dbname and write the 
# production.conf file for ubersystem

# TODO: probably rename this file from python to ubersystem
# or, move the ubersystem-specific stuff out of here.

# TODO: dont hardcode venv path, can we assign it inside the class itself

# TODO: hostname as a paramater

class uber::python (
  # modify this if you want.
  $uber_path = '/usr/local/uber',
  $ubersystem_git_repo = 'https://github.com/EliAndrewC/magfest',
  $ubersystem_git_branch = 'master',
  $uber_user = 'uber',
  $uber_group = 'apps',

  $db_host = 'localhost',
  $db_user = 'm13',
  $db_pass = 'm13',
  $db_name = 'm13',

  $socket_port = '4321',
  $socket_hostname = '0.0.0.0',
  $ubersystem_url_prefix = '/magfest',
) {

  $python_ver = '3'
  $venv_path = "${uber_path}/env"
  $venv_bin = "${uber_path}/bin"

  class { '::python':
    # ensure     => present,
    version    => $python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
  }

  # TODO install UTF lcoale stuff from Eli's Vagrant script
  package { "git": ensure => present }

  vcsrepo { $uber_path:
    ensure   => latest,
    owner    => $uber_user,
    group    => $uber_group,
    provider => git,
    source   => $ubersystem_git_repo,
    revision => $ubersystem_git_branch,
    require  => Package['git'],
    notify   => Exec['uber_virtualenv'],
  }

  $python_cmd = $python_ver ? {
    '2'     => 'python2',
    '3'     => 'python3',
    default => fail("Bad python version: ${python_ver}"),
  }

  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { 'uber_virtualenv':
    command     => "${python_cmd} -m venv ${venv_path} --without-pip",
    cwd         => $uber_path,
    path        => '/usr/bin',
    refreshonly => true,
    notify      => Exec['uber_distribute_setup'],
  }

  exec { 'uber_distribute_setup' :
    command     => "${venv_bin}/python distribute_setup.py",
    cwd         => "${uber_path}",
    refreshonly => true,
    notify      => File["${uber_path}/production.conf"],
  }

  file { "${uber_path}/production.conf":
    # TODO: add some stuff in here for db name/etc
    ensure => present,
    mode   => 660,
    content => template('uber/production.conf.erb'),
    notify      => Exec['uber_setup'],
  }

  exec { 'uber_setup' :
    command     => "${venv_bin}/python setup.py develop",
    cwd         => "${uber_path}",
    refreshonly => true,
    notify      => Exec['uber_init_db'],
  }

  # TODO: dont always do this
  exec { 'uber_init_db' :
    command     => "${venv_bin}/python uber/init_db.py",
    cwd         => "${uber_path}",
    refreshonly => true,
  }

}
