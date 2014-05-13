class postgres{
  include postgres::install, postgres::config, postgres::service
}

class postgres::install{
  package { 'postgresql':
    ensure => present
  }
}

class postgres::config{

}

class postgres::service{
  service {'postgresql':
    ensure         => running,
    enable => true,
  }
}

Class["postgres::install"] -> Class["postgres::config"] -> Class["postgres::service"]
