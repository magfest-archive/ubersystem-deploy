
#
# This module is used for holding applications with per host or per website
# parameters.  For example, different MySQL databases.
#
class autodeploy {

	file {"/etc/cron.hourly/uber-refresh":
		ensure => present,
		owner => root,
		group => root,
		mode => 750,
		content => template('autodeploy/uber-refresh.erb'),
	}

} # End of autodeploy


