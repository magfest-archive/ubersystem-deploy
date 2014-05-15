class uber_python {
  # modify this if you want.
  $uber_path = "/usr/local/uber"
  $ubersystem_git_repo = "https://github.com/EliAndrewC/magfest"
  $ubersystem_git_branch = "master"
  $uber_user = "uber"
  $uber_group = "apps"

  # probably no need to modify any of this
  $python_ver = '3'
  $venv_path = "${uber_path}/env"
  $venv_bin = "${venv_path}/bin"
  $checkout_path = $uber_path

  include python, uber_python::setup_install_dir, uber_python::setup_ubersystem, uber_python::virtualenv, uber_python::checkout_code, uber_python::finalize, uber_python::init_db
}

class { 'python':
  ensure     => present,
  version    => $uber_python::python_ver,
  dev        => true,
  pip        => true,
  virtualenv => true,
  gunicorn   => false,
}
class uber_python::setup_install_dir {
  file { $uber_python::uber_path:
    ensure  => "directory",
    owner   => $uber_python::uber_user,
    group   => $uber_python::uber_group,
    mode    => 660,
    notify   => Class['uber_python::checkout_code']
  }
}
class uber_python::checkout_code {
  package { "git": ensure => present }
  package { "python3-dev": ensure => present }
  #package { "python3-pip": ensure => present } # dont think we need it
  #package { "python-pip": ensure => present }  # dont think we need it
  # TODO UTF stuff in Eli's Vagrant script

  vcsrepo { $uber_python::checkout_path:
    ensure   => latest,
    provider => git,
    source   => $uber_python::ubersystem_git_repo,
    revision => $uber_python::ubersystem_git_branch,
    require  => Package['git'],
    notify   => Class['uber_python::virtualenv']
  }
}
class uber_python::virtualenv {
  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { 'virtualenv':
    command     => "python${uber_python::python_ver} -m venv ${uber_python::venv_path} --without-pip",
    cwd         => $uber_python::uber_path,
    path        => '/usr/bin',
    refreshonly => true,
    notify      => Class['uber_python::setup_ubersystem']
  }
}
class uber_python::setup_ubersystem {
  exec { 'distribute_setup' :
    command => "${uber_python::venv_bin}/python distribute_setup.py",
    cwd     => "${uber_python::uber_path}",
  }->
  exec { 'setup' :
    command => "${uber_python::venv_bin}/python setup.py develop",
    cwd     => "${uber_python::uber_path}",
    notify  => Class['uber_python::init_db'],
  }
}
class uber_python::init_db {
  exec { 'init_uber_db' :
    command => "${uber_python::venv_bin}/python uber/init_db.py",
    cwd     => "${uber_python::uber_path}",
    notify  => Class['uber_python::finalize'],
  }
}
class uber_python::finalize {
  exec { 'change owner+group of uber dir':
    command => "/bin/chown -R ${uber_python::uber_user}.${uber_python::uber_group} ${uber_python::uber_path}",
    cwd     => $uber_python::uber_path,
  }
}
