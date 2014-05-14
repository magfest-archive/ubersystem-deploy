class uber_python {
  # modify this if you want.
  $uber_path = "/usr/local/uber"
  $ubersystem_git_repo = "https://github.com/EliAndrewC/magfest"
  $ubersystem_git_branch = "master"
  $uber_user = "uber"
  $uber_group = "apps"

  # probably no need to modify any of this
  $python_ver = '3.4'
  $venv_path = "${uber_path}/env"
  $checkout_path = $uber_path

  include python, uber_python::setup_install_dir, uber_python::setup_ubersystem, uber_python::checkout_code, uber_python::finalize
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
  }
}
class uber_python::checkout_code {
  package { "git": ensure => present }

  vcsrepo { $uber_python::checkout_path:
    ensure   => latest,
    provider => git,
    source   => $uber_python::ubersystem_git_repo,
    revision => $uber_python::ubersystem_git_branch,
    require  => Package['git'],
    before   => Class['uber_python::finalize']
  }
}
class uber_python::virtualenv {
  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { 'virtualenv':
    command     => "python{$uber_python::python_ver} -m venv ${uber_python::uber_path}",
    cwd         => $uber_python::uber_path,
    refreshonly => true,
  }
}
class uber_python::setup_ubersystem {
  notify { 'todo' :}
}
class uber_python::finalize {
  exec { 'change owner+group of uber dir':
    command => "/bin/chown -R ${uber_python::uber_user}.${uber_python::uber_group} ${uber_python::uber_path}",
    cwd     => $uber_python::uber_path,
    require => Class['uber_python::setup_ubersystem']
  }
}

Class['python']->
Class['uber_python::setup_install_dir']->
Class['uber_python::checkout_code']->
Class['uber_python::virtualenv']->
Class['uber_python::setup_ubersystem']->
Class['uber_python::finalize']
