
#
# Install a new sources.list with universe and update our software listing
#
class software::apt-get ($os = "ubuntu") {

	if $os == "ubuntu" {
		$source = "puppet:///modules/software/sources.list"

	} else {
		warning("Unknown OS: ${os}. Can't select source file.")

	}

	#file {"/etc/apt/sources.list":
	#	source => $source,
	#	owner => root,
	#	group => root,
	#	mode => 0644,
	#	notify => Exec["apt-update"],
	#}

	#
	# Run apt-get ONLY if it hasn't been previously run
	#
	file { "/opt/puppet/":
		ensure => directory,
		mode => 0755,
	}

	file { "/opt/puppet/var":
		require => File["/opt/puppet/"],
		ensure => directory,
		mode => 0755,
	}

	exec { "apt-update":
		require => File["/opt/puppet/var/"],
		creates => "/opt/puppet/var/apt-get-update",
		command => "/usr/bin/apt-get update",
	}

	exec { "touch /opt/puppet/var/apt-get-update":
		require => Exec["apt-update"],
	}

}


