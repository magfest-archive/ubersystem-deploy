

#
# Install iptables-persistent
#
define software::iptables-persistent() {

	package {"iptables-persistent":
		ensure => present,
	}

} # End of iptables-persistent()

