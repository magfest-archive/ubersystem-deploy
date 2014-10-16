

#
# Install the AWS command-line client.
#
class software::awscli (
	$aws_access_key = "FIXME",
	$aws_secret_key = "FIXME",
	$user = "root"
	) {

	package {"python-pip": }

	exec {"install awscli":
		command => "pip install awscli",
		require => Package["python-pip"],
	}
		
	file {"/home/${user}/.aws":
		ensure => directory,
		owner => $user,
		group => $user,
		mode => 0700,
	}

        file {"/home/${user}/.aws/config":
		content => template("software/aws-config.erb"),
		owner => $user,
		group => $user,
		mode => 0400,
		require => File["/home/${user}/.aws"],
        }


}


