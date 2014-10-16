
#
# Install the scripts for database creation
#
class apps::mysql::database_create_files() {

	file {"/opt/puppet-bin/mysql-database-create":
		source => "puppet:///modules/apps/mysql/database-create",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin"],
	}

}

