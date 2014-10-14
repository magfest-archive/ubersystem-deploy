
#
# Create a database
#
define apps::mysql::database_create() {

	include apps
	include apps::mysql::database_create_files

	exec {"Create Database $name":
		command => "/opt/puppet-bin/mysql-database-create ${name}",
		creates => "/opt/puppet-bin/beenhere-mysql-database-create-${name}",
		logoutput => true,
		require => [
			Service["mysql"], File["/opt/puppet-bin/mysql-database-create"],
			],
	}

} # End of database_create()


