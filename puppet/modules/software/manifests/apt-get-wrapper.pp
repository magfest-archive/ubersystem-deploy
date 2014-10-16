
#
# Wrapper for apt-get update
#
class software::apt-get-wrapper ($os = "ubuntu") {

	#
	# Set up our staging
	#
	stage { ['pre', 'post']: }
	Stage['pre'] -> Stage['main'] -> Stage['post']

	#
	# Install our new sources.list and call apt-get update
	#
	class { "software::apt-get": 
		stage => "pre",
		os => $os,
	}

}

