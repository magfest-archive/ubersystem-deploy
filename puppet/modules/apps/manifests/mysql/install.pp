
#
# Install MySQL
#
define apps::mysql::install($key_buffer = "8M",
	$query_cache_limit = "1M",
	$query_cache_size = "16M",
	$key_buffer = "16M",
	$innodb_flush_log_at_trx_commit = "2",
	$innodb_buffer_pool_size = "16M",
	$tmp_table_size = "16M",
	$max_heap_table_size = "16M",
	$table_cache = "128",
	$table_open_cache = "128"
	) {

	package{"mysql-server":
		ensure => present,
	}

	service{"mysql":
		ensure => running,
	}

	file{"/etc/mysql/my.cnf":
		path => "/etc/mysql/my.cnf",
		content => template("apps/mysql/my.cnf.erb"),
		notify => Service["mysql"],
	}

	Package["mysql-server"]->File["/etc/mysql/my.cnf"]->Service["mysql"]

} # End of install()


