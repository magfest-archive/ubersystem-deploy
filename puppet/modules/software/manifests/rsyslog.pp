
#
# Make sure that permissions are set correctly on rsyslog, 
# since Digital Ocean screwed it up.
#

class software::rsyslog {

	file {"/var/log/messages":
		owner => syslog,
		group => adm,
		mode => 0644,
	}

	file {"/var/log/debug":
		owner => syslog,
		group => adm,
		mode => 0644,
	}

	file {"/var/log/syslog":
		owner => syslog,
		group => adm,
		mode => 0644,
	}

}


