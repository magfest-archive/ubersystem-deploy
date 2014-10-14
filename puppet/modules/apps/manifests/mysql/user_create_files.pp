
#
# Install our scripts for user creation
#
class apps::mysql::user_create_files() {

	file {"/opt/puppet-bin/mysql-database-user-create":
		source => "puppet:///modules/apps/mysql/database-user-create",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin"],
	}

}


