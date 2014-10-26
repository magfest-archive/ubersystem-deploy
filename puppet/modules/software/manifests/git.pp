

class software::git() {
	if defined(Package['git']) == false {
		package{"git":
			ensure => installed,
		}
	}
}


