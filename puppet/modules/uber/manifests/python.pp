# TODO: probably rename this file from python to ubersystem
# or, move the ubersystem-specific stuff out of here.

# TODO: hostname as a paramater

# TODO: dependency chain in here is slightly busted.

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
  $socket_host = '0.0.0.0',
  $hostname = '', # defaults to hostname of the box
  $ubersystem_url_prefix = '/magfest',

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
    source   => $ubersystem_git_repo,
    revision => $ubersystem_git_branch,
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
  }

}
