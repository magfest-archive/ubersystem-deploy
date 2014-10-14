
#
# Initial things, such as creating groups and /etc/sudoers.
#
define user::start() {

	group {"admin":
		name => "admin",
		ensure => present,
	}

	file {"/etc/sudoers":
		source => "puppet:///modules/user/sudoers",
		owner => root,
		group => root,
		mode => 0440,
	}

}

