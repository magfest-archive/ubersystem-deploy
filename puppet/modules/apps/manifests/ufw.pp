
#
# Set up our firewall
#
class apps::ufw {

	#
	# Documentation: https://forge.puppetlabs.com/attachmentgenie/ufw
	#
	include ::ufw

	exec {"ufw enable":
		command => "ufw --force enable"
	}

	#
	# This is a bit of a hack, because on an empty 
	# ruleset "insert 1" won't work.  I figured that rather than 
	# rewriting the UFW module (which is third-party), I would just
	# insert a harmless rule here.
	#
	exec {"ufw hack":
		command => "ufw allow from 127.0.0.1 to 127.0.0.1 port 81 proto tcp"
	}

	ufw::allow { "allow-ssh-from-all":
		port => 22,
		ip => "any",
		#require => [ Ufw::Allow["port 81"] ],
		require => [ Exec["ufw hack"] ],
	}

	ufw::allow { "allow-http-from-all":
		port => 80,
		ip => "any",
		#require => [ Ufw::Allow["port 81"] ],
		require => [ Exec["ufw hack"] ],
	}
	
	ufw::allow { "allow-https-from-all":
		port => 443,
		ip => "any",
		#require => [ Ufw::Allow["port 81"] ],
		require => [ Exec["ufw hack"] ],
	}

	#
	# NOTES:
	# - If you use a subnet, the resource will be executed EVERY TIME. I warned ya.
	# - Make sure to use the require, so that the allow directives are executed FIRST.
	#	This is because what is happening under the hood is an "insert", so we
	#	want our denys inserted before the allows, which means they need to be 
	#	executed later.
	#
	ufw::deny { "93.216.7.213 too many requests":
		from => "93.216.7.213",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Steephost.net spammer":
		from => "93.0.0.0/8",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Abusive crawling of saveardmorecoalition.org":
		from => "37.115.188.27",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Repeated attempts to register on www.saveardmorecoalition.org from 233.140 and 233.164":
		from => "199.15.233.0/24",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Referrer spam":
		from => "5.10.83.31",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Poorly behaved crawler":
		from => "91.207.6.6/16",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "'Illegal choice in vote element' errors in the logs.":
		from => "94.100.24.185",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Hit anthrocon.org with 4K requests, causing a DoS":
		from => "91.207.7.253",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Referrer spam to the AC website":
		from => "31.184.236.8",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over":
		from => "184.75.211.123",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over2":
		from => "54.72.81.94",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over3":
		from => "217.78.1.63",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over4":
		from => "217.78.0.0/24",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over5":
		from => "217.78.1.0/24",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over6":
		from => "184.107.104.190",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over7":
		from => "54.186.29.75",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over8":
		from => "191.238.55.48",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over9":
		from => "174.142.179.117",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

	ufw::deny { "Loading the same URL over and over10":
		from => "67.205.92.42",
		proto => "any",
		require => [ Ufw::Allow["allow-ssh-from-all"], Ufw::Allow["allow-http-from-all"], Ufw::Allow["allow-https-from-all"], ]
	}

}

