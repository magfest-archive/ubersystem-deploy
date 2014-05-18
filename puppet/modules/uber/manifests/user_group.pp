class uber::user_group(
  $uber_user,
  $uber_group, 
){
  group { $uber_group:
    ensure => present,
  }

  user { $uber_user:
    ensure     => 'present',
    groups     => [$uber_group],
    home       => "/home/${uber_user}",
    managehome => true,
    shell      => '/bin/bash',
    require    => Group[$uber_group],
  }
}
