
#
# Remove the crontab for our backup system.
#
define apps::no_backups_to_s3() {

	cron {"backups to s3":
		command => $cmd,
		ensure => absent,
	}


}


