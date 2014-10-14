

define user::s3_keys_add ($s3_access_key, $s3_secret_key) {

	$access_key = $s3_access_key
	$secret_key = $s3_secret_key
	file {"/home/${name}/.s3cfg":
		content => template("user/dot-s3cfg"),
		require => File["/home/${name}"],
	}

} # s3_keys_add()


