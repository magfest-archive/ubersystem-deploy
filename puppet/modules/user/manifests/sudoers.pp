
#
# Install sudoers and put $name in it
#
define user::sudoers() {

	file {"/etc/sudoers":
		content => template("user/sudoers.erb"),
		owner => root,
		group => root,
		mode => 0440,
	}

}


