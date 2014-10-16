

#
# This is a "core" manifest.  Just create the core user.
#
define user::create_core($machine_name) {

	group {"admin":
		name => "admin",
		ensure => present,
	}

	user {$name:
		name => $name,
		ensure => present,
		groups => ["admin"],
		shell => "/bin/bash",
		require => Group["admin"],
	}

	file {"/home/${name}":
		ensure => directory,
		owner => $name,
		group => $name,
		mode => 0700,
	}

	file {"/home/${name}/.gitconfig":
		content => template("user/dot-gitconfig"),
		owner => $name,
		group => $name,
		require => File["/home/${name}"],
	}

	file {"/home/${name}/.profile":
		content => template("user/dot-profile"),
		owner => $name,
		group => $name,
		require => File["/home/${name}"],
	}

	file {"/home/${name}/.bashrc":
		content => template("user/dot-bashrc"),
		owner => $name,
		group => $name,
		require => File["/home/${name}"],
	}

	file {"/home/${name}/www":
		ensure => link,
		target => "/var/www",
		owner => $name,
		group => $name,
		require => File["/home/${name}"],
	}

} # End of create_core()


