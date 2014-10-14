
#
# This module is used for holding applications with per host or per website
# parameters.  For example, different MySQL databases.
#
class apps {

	file {"/opt/puppet-bin/":
		path => "/opt/puppet-bin/",
		ensure => directory,
		owner => root,
		group => root,
	}

} # End of apps


