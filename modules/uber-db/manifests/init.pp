class { 'postgresql::server':
  ip_mask_deny_postgres_user  => '0.0.0.0/32',
  ip_mask_allow_all_users   => '0.0.0.0/0',
  listen_addresses        => '127.0.0.1',
  #ipv4acls              => ['hostssl all johndoe1 192.168.0.0/24 cert'],
  manage_firewall     => true,
  #postgres_password => 'TPSrep0r234t!',
}

class uber-db {
  include postgresql::server, postgres::install, postgres::config
}

class postgres::install{
  package { 'postgresql':  ensure        => present }
  package { 'postgresql-contrib': ensure => present }
  package { 'libpq-dev': ensure          => present }
}

class postgres::config{
  postgresql::server::db { 'm13':
    user         => 'm13',
    password => postgresql_password('m13', 'm13'),
  }
}

Class["postgres::install"] -> Class["postgres::config"] -> Class["postgressql::server"]
