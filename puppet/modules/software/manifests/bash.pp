

define software::bash() {

	package{"bash":
		ensure => latest,
		require => Exec["apt-update"],
	}

}


