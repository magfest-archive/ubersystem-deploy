
#
# Install our DNS resolver settings
#
define apps::dns() {

	file {"/etc/resolv.conf":
		source => "puppet:///modules/apps/resolv.conf",
		owner => root,
		group => root,
		mode => 0644,
	}

}

