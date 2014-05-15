class uber-users
{
  # users in this group can sudo
  group { "admin":
    ensure  => present
  }

  # users in this group can edit app files
  group { "apps":
    ensure  => present
  }

	user { 'uber':
	    ensure => 'present',
	    groups => ['apps'], # sudo access
	    home => '/home/uber',
	    managehome => true,
	    password => '$876328756873465876345', # JUNK # '$6$lY2Gp3Cr$zNrUB7T3yibUF/gWn5cTQ0fNv7MUmx/DZuw3E7I..Vh9tITG28BtgvXJPU4Gm4Z/9oNvlbX24KzQ9Ib1QH1B9.', # hash for test. TODO: change
	    shell => '/bin/bash',
	}
}
