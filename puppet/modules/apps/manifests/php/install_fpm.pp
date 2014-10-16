
#
# Install PHP FPM
#
define apps::php::install_fpm($max_children = 4) {

	package {"php5-fpm":}

	package {"php5-mysql":}

	package {"php5-gd":}

	package {"php5-curl":}

	service{"php5-fpm":
		ensure => running,
		enable => true,
	}

	file {"/etc/php5/fpm/php.ini":
		content => template("apps/php/php5-fpm-php.ini.erb"),
		notify => Service["php5-fpm"],
	}

	file {"/etc/php5/fpm/pool.d/www.conf":
		content => template("apps/php/php5-fpm-pool.d-www.conf.erb"),
		notify => Service["php5-fpm"],
	}

	Package["php5-fpm"]->Package["php5-mysql"]
		->Package["php5-gd"]->Package["php5-curl"]
		->Service["php5-fpm"]

}

