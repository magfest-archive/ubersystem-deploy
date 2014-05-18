class uber::install 
(
  $db_user = $uber::globals::db_user,
/*  $db_pass,
  $db_name,
  $uber_path,
  $git_repo,
  $git_branch,
  $url_prefix,
  $socket_port,
  $uber_user,
  $uber_group,*/
) inherits uber::globals {

  notify {"STUFF: ${db_user}": }

  /*(uber::user_group { "users and groups ${name}":
    uber_user  => $uber_user,
    uber_group => $uber_group,
  }*/

  /*uber::db { "ubersystem database ${name}":
    user   => $db_user,
    pass   => $db_pass,
    dbname => $db_name,
  }

  uber::python { "ubersystem setup ${name}":
    db_user      => $db_user,
    db_pass      => $db_pass,
    db_name      => $db_name,
    uber_path    => $uber_path,
    git_repo     => $git_repo,
    git_branch   => $git_branch,
    url_prefix   => $url_prefix,
    socket_port  => $socket_port,
    uber_user    => $uber_user,
    uber_group   => $uber_group,
  }*/
}
