
#
# Set up our backup system
#
# @param {string} $backup_exclude A list of files or directories to NOT back up
#
# @param {string} $prefix The prefix to use in the S3 bucket.  This way, 
#	multiple machines can be backed up to the same bucket, if necessary
#
define apps::backups_to_s3($s3_bucket, $prefix, $backup_exclude) {

	package{"duplicity":
		ensure => installed
	}

	file {"/backups":
		ensure => directory,
		mode => 0700,
		owner => root,
		group => root,
	}

	file {"/var/www/backups-mysql":
		ensure => directory,
		mode => 0700,
		owner => root,
		group => root,
	}

	file {"/var/backups-mysql-history":
		ensure => directory,
		mode => 0700,
		owner => root,
		group => root,
	}

	file {"/opt/puppet-bin/backup-duplicity":
		source => "puppet:///modules/apps/backup-duplicity",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin/"],
	}

	file {"/opt/puppet-bin/backup-mysql":
		source => "puppet:///modules/apps/backup-mysql",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin/"],
	}

	file {"/opt/puppet-bin/backup-to-s3":
		source => "puppet:///modules/apps/backup-to-s3",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin/"],
	}

	#
	# Put this onto a machine that does backups in case we have to restore
	#
	file {"/opt/puppet-bin/restore-from-s3":
		source => "puppet:///modules/apps/restore-from-s3",
		mode => 0755,
		owner => root,
		group => root,
		require => [
			File["/opt/puppet-bin/"], Package["duplicity"],
			],
	}

	file {"/opt/puppet-bin/cron-backup-to-s3":
		source => "puppet:///modules/apps/cron-backup-to-s3",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin/"],
	}

	$hour = 5
	$minute = 30
	#$hour = 19 # Debugging
	#$minute = 27 # Debugging
	$cmd = "/opt/puppet-bin/cron-backup-to-s3 $s3_bucket ${prefix} '$backup_exclude' 2>&1 |logger -t backups "
	cron {"backups to s3":
		command => $cmd,
		ensure => present,
		#ensure => absent, # Set this on testing/dev
		user => root,
		hour => $hour,
		minute => $minute,
	}


}


