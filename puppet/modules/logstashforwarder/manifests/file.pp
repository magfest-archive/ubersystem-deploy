define logstashforwarder::file (
    $paths,
    $fields,
    $deadtime = undef,
){
    
    File {
        owner => 'root',
        group => 'root',
    }

    if ($paths != '') {
        validate_array($paths)
    }

    # Let's have the option of using an array OR a hash.  Arrays are nice
    # because they shouldn't be randomly re-ordered.
    # requies stdlib
    # The validate step may or may not be silly depending on if it's more
    # comprehensive than the is_hash/is_array functions.
    if is_hash($fields) {
      validate_hash($fields)
      $fields_to_template = $fields
    }
    
    elsif is_array($fields) {
      validate_array($fields)
      # Here we convert the array to a hash.  Puppet doesn't SEEM to
      # munge hashes when it passes them to templates... maybe.
      # Note that sub-arrays are not supported.
      $fields_to_template = hash($fields)
    }
    
    else {
      fail('fields must be either an array or a hash!')
    }

    if ($logstashforwarder::ensure == 'present' ) { 
        concat::fragment{"${name}":
            target  => "${logstashforwarder::configdir}/${logstashforwarder::config}",
            content => template("${module_name}/file_format.erb"),
            order   => 010,
        }
    }
}
