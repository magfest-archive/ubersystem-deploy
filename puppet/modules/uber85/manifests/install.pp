class uber::install {

  # TODO install UTF lcoale stuff from Eli's Vagrant script
  package { "git": 
    ensure => present 
  }
  package { 'postgresql':
    ensure => present,
  }
  package { 'postgresql-contrib':
    ensure => present,
  }
  package { 'libpq-dev':
    ensure => present,
  }

  class {'uber::python': }
}
