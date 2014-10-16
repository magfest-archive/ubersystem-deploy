
#
#  Install screen and a user's screenrc
#
define user::screen() {

	software::screen{"screen":}

	$shelltitle = $machine_name
	file {"/home/${name}/.screenrc":
		content => template("user/dot-screenrc"),
		owner => $name,
		group => $name,
		require => File["/home/${name}"],
	}

}


