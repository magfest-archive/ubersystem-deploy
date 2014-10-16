
#
# Set up Munin and a bunch of plugins
#
class software::munin-mysql() {

	$dir = "/etc/munin/plugins"
	$source = "/usr/share/munin/plugins"

	#
	# Add in a bunch of MySQL plugins
	#
	file {"${dir}/mysql_bytes":
		ensure => symlink,
		target => "${source}/mysql_bytes",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb":
		ensure => symlink,
		target => "${source}/mysql_innodb",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_queries":
		ensure => symlink,
		target => "${source}/mysql_queries",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_slowqueries":
		ensure => symlink,
		target => "${source}/mysql_slowqueries",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_threads":
		ensure => symlink,
		target => "${source}/mysql_threads",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	#
	# Now add options for the core MySQL plugin
	#
	file {"${dir}/mysql_bin_relay_log":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_commands":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_connections":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_files_tables":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_bpool":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_bpool_act":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_insert_buf":
		ensure => absent,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_io":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_io_pend":
		ensure => absent,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_log":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_rows":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_semaphores":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_innodb_tnx":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_myisam_indexes":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_network_traffic":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_qcache":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_qcache_mem":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_replication":
		ensure => absent,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_select_bytes":
		ensure => absent,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_slow":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_sorts":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_table_locks":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

	file {"${dir}/mysql_tmp_tables":
		ensure => symlink,
		target => "${source}/mysql_",
		require => [ 
			Package["munin"], Package["munin-plugins-extra"],
			],
		notify => Service["munin-node"],
	}

}


