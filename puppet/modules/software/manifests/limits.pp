
#
# Write our limits.conf file
#
define software::limits {

	file {"/etc/pam.d/common-session":
		source => "puppet:///modules/software/etc-pam.d-common-session",
		owner => root,
		group => root,
	}


	file {"/etc/security/limits.conf":
		source => "puppet:///modules/software/limits.conf",
		owner => root,
		group => root,
	}

}


