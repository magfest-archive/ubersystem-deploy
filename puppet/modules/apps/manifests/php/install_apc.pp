
#
# Install APC
#
define apps::php::install_apc($shm_size) {

	package {"php-apc":
		notify => Service["php5-fpm"],
	}

	#	
	# This doesn't appear to be needed in Ubuntu 14.04...
	#
	#file {"/etc/php5/mods-available/apc.ini":
	#	content => template("apps/php/apc.ini.erb"),
	#	notify => Service["php5-fpm"],
	#}


}

