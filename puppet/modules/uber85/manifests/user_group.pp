define uber85::user_group(
  $user,
  $group, 
){

  if ! defined(Group[$group]) {
    group { $group:
     ensure => present,
   }
  }

  if ! defined(User[$user]) {
    user { $user:
     ensure     => 'present',
     groups     => [$group],
     home       => "/home/${user}",
     managehome => true,
     shell      => '/bin/bash',
     require    => Group[$group],
   }
  }
}
