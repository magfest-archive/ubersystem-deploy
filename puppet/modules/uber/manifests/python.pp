# TODO: add in database user/password/dbname and write the 
# production.conf file for ubersystem

# TODO: probably rename this file from python to ubersystem
# or, move the ubersystem-specific stuff out of here.

class uber::python (
  # modify this if you want.
  $uber_path = '/usr/local/uber',
  $ubersystem_git_repo = 'https://github.com/EliAndrewC/magfest',
  $ubersystem_git_branch = 'master',
  $uber_user = 'uber',
  $uber_group = 'apps',

  # probably no need to modify any of this
  $python_ver = '3',
  $venv_path = '/usr/local/uber/env',
  $venv_bin = '/usr/local/uber/bin',
) {

  class { '::python':
    # ensure     => present,
    version    => $python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
  }

  package { "git": ensure => present }
  # package { "python3-dev": ensure => present }
  #package { "python3-pip": ensure => present } # dont think we need it
  #package { "python-pip": ensure => present }  # dont think we need it
  # TODO UTF stuff in Eli's Vagrant script

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
    notify      => Exec['uber_setup'],
  }

  exec { 'uber_setup' :
    command     => "${venv_bin}/python setup.py develop",
    cwd         => "${uber_path}",
    refreshonly => true,
    notify      => Exec['uber_init_db'],
  }

  exec { 'uber_init_db' :
    command     => "${venv_bin}/python uber/init_db.py",
    cwd         => "${uber_path}",
    refreshonly => true,
  }

}
