# Class uber::db
#
# Document the class here
#
# No newline after comment
class uber::db (
  $user = 'default_user',
  $pass = 'default_pass',
) {

  package { 'postgresql':
    ensure => present,
  }
  package { 'postgresql-contrib':
    ensure => present,
  }
  package { 'libpq-dev':
    ensure => present,
  }

  postgresql::server::db { 'm13':
    user     => $user,
    password => postgresql_password($user, $pass),
    require  => [
      Package['postgresql'],
      Package['postgresql-contrib'],
      Package['libpq-dev'],
    ],
  }

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => '127.0.0.1',
    #ipv4acls                  => ['hostssl all johndoe1 192.168.0.0/24 cert'],
    manage_firewall            => true,
    #postgres_password         => 'TPSrep0r234t!',
    require                    => Postgresql::Server::Db['m13'],
  }
}
