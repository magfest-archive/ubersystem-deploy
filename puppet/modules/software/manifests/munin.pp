
#
# Set up Munin and a bunch of plugins
#
class software::munin() {

	package {"munin":
		ensure => present,
	}

	package {"munin-plugins-extra": 
		ensure => present,
	}

	package {"libcache-cache-perl":
		ensure => present,
	}

        package {"libwww-perl":
                ensure => present,
        }

	service {"munin-node":
		ensure => running,
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			Package["libcache-cache-perl"] 
			],
	}

        $confdir = "/etc/munin"
	$dir = "/etc/munin/plugins"
	$source = "/usr/share/munin/plugins"

	#
	# Removed unused plugins
	#
	file {"${dir}/nfs4_client":
		ensure => absent,
		notify => Service["munin-node"],
	}

	file {"${dir}/nfs_client":
		ensure => absent,
		notify => Service["munin-node"],
	}

	file {"${dir}/nfsd":
		ensure => absent,
		notify => Service["munin-node"],
	}

	file {"${dir}/nfsd4":
		ensure => absent,
		notify => Service["munin-node"],
	}

	#
	# Misc modules
	#
	file {"${dir}/fail2ban":
		ensure => symlink,
		target => "${source}/fail2ban",
		notify => Service["munin-node"],
	}
        #
	# Add htaccess file
	# 
	file {"${confdir}/munin-htpasswd":
		ensure => present,
		owner => root,
		group => root,
		mode => 666,
		replace => true,
		source => "puppet:///modules/software/htpasswd",
	}
		
	
}


