
#
# Create a database user
#
define apps::mysql::user_create($username, $password, $db) {

	include apps
	include apps::mysql::user_create_files

	exec {"Create MySQL User $name":
		command => "/opt/puppet-bin/mysql-database-user-create $username $password $db",
		creates => "/opt/puppet-bin/beenhere-mysql-database-user-create-${db}",
		logoutput => true,
		require => [ 
			Service["mysql"], File["/opt/puppet-bin/mysql-database-user-create"],
			Apps::Mysql::Database_create["$db"],
			],
	}

} # End of install()


