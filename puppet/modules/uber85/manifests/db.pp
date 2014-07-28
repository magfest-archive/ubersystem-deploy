# Class uber::db
#
# Document the class here
#
# No newline after comment
define uber::db (
  $user,
  $pass,
  $dbname,
) {

  # enforce that each uber database must be unique.
  # re-work if we ever want to support multiple ubers using the same DB
  if defined(Postgresql::Server::Db[$dbname])
  {
    fail("ERROR: multiple uber installations are trying to use the same database. this is not supported, each uber install needs to use it's own database.")
  }

  postgresql::server::db { $dbname:
    user     => $user,
    password => postgresql_password($user, $pass),
    require  => Service['postgresql'],
  }
}
