# Class uber::db
#
# Document the class here
#
# No newline after comment
define uber::db (
  $user = 'default_user',
  $pass = 'default_pass',
  $dbname = 'default_dbname',
) {
  postgresql::server::db { $dbname:
    user     => $user,
    password => postgresql_password($user, $pass),
    require  => Service['postgresql'],
  }
}
