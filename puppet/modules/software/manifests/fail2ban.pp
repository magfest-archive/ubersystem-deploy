

#
# Install fail2ban
#
define software::fail2ban() {

	package {"fail2ban":
		alias => "fail2ban $name",
		ensure => present,
	}

	service {"fail2ban":
		alias => "fail2ban $name",
		ensure => running,
	}

	Package["fail2ban"]->Service["fail2ban"]

} # End of fail2ban()

