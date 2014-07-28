class uber85::install {

  # TODO install UTF lcoale stuff from Eli's Vagrant script
  if defined(Package['git']) == false {
    package { 'git': 
      ensure => present 
    }
  }

  if defined(Package['postgresql']) == false {
    package { 'postgresql':
      ensure => present,
    }
  }

  if defined(Package['postgresql-contrib']) == false {
    package { 'postgresql-contrib':
      ensure => present,
    }
  }

  if defined(Package['libpq-dev']) == false {
    package { 'libpq-dev':
      ensure => present,
    }
  }

  class {'uber85::python': }
}
