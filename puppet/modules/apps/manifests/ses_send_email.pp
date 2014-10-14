
#
# Install our scripts to send email via Amazon SES
#
define apps::ses_send_email($ses_access_key, $ses_secret_key) {

	file {"/opt/puppet-bin/ses":
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin"],
	}

	file {"/opt/puppet-bin/ses/SES.pm":
		source => "puppet:///modules/apps/ses/SES.pm",
		owner => root,
		group => root,
		mode => 0644,
		require => File["/opt/puppet-bin/ses"],
	}

	file {"/opt/puppet-bin/ses/ses-send-email.pl":
		source => "puppet:///modules/apps/ses/ses-send-email.pl",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin/ses"],
	}

	$access_key = $ses_access_key
	$secret_key = $ses_secret_key
	file {"/home/ubuntu/.aws-ses-credentials":
		content => template("apps/aws-ses-credentials.erb"),
		owner => ubuntu,
		group => ubuntu,
		mode => 0400,
		require => File["/home/ubuntu"],
	}

	#
	# Do the same for the web user, as it runs webserver crontabs
	#
	file {"/home/web/.aws-ses-credentials":
		content => template("apps/aws-ses-credentials.erb"),
		owner => web,
		group => web,
		mode => 0400,
		require => File["/home/web"],
	}

	file {"/opt/puppet-bin/ses-send-email":
		source => "puppet:///modules/apps/ses/ses-send-email",
		owner => root,
		group => root,
		mode => 0755,
		require => File["/opt/puppet-bin"],
	}

}

