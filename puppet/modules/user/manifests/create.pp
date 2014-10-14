

#
# Create a new user
#
define user::create($machine_name) {

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

	#
	# Some helpful configuration files
	#
	file {"/home/${name}/.gitconfig":
		content => template("user/dot-gitconfig"),
		require => File["/home/${name}"],
	}

	file {"/home/${name}/.profile":
		content => template("user/dot-profile"),
		require => File["/home/${name}"],
	}

	file {"/home/${name}/.bashrc":
		content => template("user/dot-bashrc"),
		require => File["/home/${name}"],
	}

	$shelltitle = $machine_name
	file {"/home/${name}/.screenrc":
		content => template("user/dot-screenrc"),
		require => File["/home/${name}"],
	}

	file {"/home/${name}/.tmux.conf":
		content => template("user/dot-tmux.conf"),
		owner => $name,
		group => $name,
		require => File["/home/${name}"],
	}

	file {"/home/${name}/.tmux.reset.conf":
		content => template("user/dot-tmux.reset.conf"),
		owner => $name,
		group => $name,
		require => File["/home/${name}"],
	}  
	#
	# Symlink to our folder containing document roots
	#
	file {"/home/${name}/www":
		ensure => link,
		target => "/var/www",
		require => File["/home/${name}"],
	}

} # End of create()


