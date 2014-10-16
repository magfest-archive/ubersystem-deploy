
#
# Nginx munin plugins
#
class software::munin-nginx() {

	$dir = "/etc/munin/plugins"
	$source = "/usr/share/munin/plugins"

	file {"${dir}/nginx_request":
		ensure => absent,
		target => "${source}/nginx_request",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/nginx_status":
		ensure => symlink,
		target => "${source}/nginx_status",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

}


