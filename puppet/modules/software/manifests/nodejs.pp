
#
# Set up node.js
#
class software::nodejs() {

	package {"python-software-properties":
		ensure => present,
	}

	exec {"add-apt node":
		command => "add-apt-repository ppa:chris-lea/node.js",
		creates => "/opt/puppet-nodejs",
		require => Package["python-software-properties"],
	}

	exec {"apt-get update node":
		command => "apt-get update",
		creates => "/opt/puppet-nodejs",
		require => Exec["add-apt node"],
	}

	package {"nodejs":
		ensure => present,
		require => Exec["apt-get update node"],
	}

	exec {"add-apt node2":
		command => "touch /opt/puppet-nodejs",
		creates => "/opt/puppet-nodejs",
		require => Package["nodejs"],
	}

}


