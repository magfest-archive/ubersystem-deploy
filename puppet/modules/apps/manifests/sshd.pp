

#
# Install our sshd file that doesn't allow root logins
#
define apps::sshd() {

	service {"ssh":
		ensure => running,
		enable => true,
	}

	file {"sshd":
		path => "/etc/ssh/sshd_config",
		source => "puppet:///modules/apps/sshd_config",
		owner => root,
		group => root,
		notify => Service["ssh"],
	}

}


