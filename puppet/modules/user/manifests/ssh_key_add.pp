

define user::ssh_key_add () {

	file{"$ssh_key dir - $name":
		path => "/home/${name}/.ssh",
		ensure => directory,
		mode => 0700,
		owner => $name,
		group => $name,
	}

	file{"/home/${name}/.ssh/authorized_keys":
		source => "puppet:///modules/user/${name}.pub",
		mode => 0400,
		owner => $name,
		group => $name,
	}


} # ssh_key_add()


