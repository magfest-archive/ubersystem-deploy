# either specify SSL certs, or generate them

class ssl_setup {
  group { "certs":
    ensure => "present",
  }
}

class generate_self_signed_ssl_certs (
  $base_name    = 'selfsigned',
  $country      = 'US',
  $organization = 'test.com',
  $commonname   = 'test.com',
  $base_dir = '/etc/ssl/certs',
  $ensure = present,
  $days = 365,
  $password = undef,
  $cnf_tpl = 'openssl/cert.cnf.erb',
  $owner = 'root',
  $group = 'certs',
  $state = undef,
  $locality = undef,
  $unit = undef,
  $altnames = [],
  $email = undef,
  $force = true,
)
{
  # generate the CA cert, key, and CSR
  openssl::certificate::x509 { "${base_name}CA":
    country      => $country,
    organization => $organization,
    commonname   => $commonname,
    base_dir     => $base_dir,
    ensure       => $ensure,
    owner   => $owner,
    group   => $group,
  }

  # generate private key for selfsignedHOST
  ssl_pkey { "${base_dir}/${base_name}HOST.key":
    ensure   => $ensure,
    password => $password,
  }

  file {"${base_dir}/${base_name}HOST.cnf":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    content => template($cnf_tpl),
  }

  # generate CSR for host key
  # openssl req -new -key host.key -out host.csr
  x509_request { "${base_dir}/${base_name}HOST.csr":
    ensure      => $ensure,
    template    => "${base_dir}/${base_name}HOST.cnf",
    private_key => "${base_dir}/${base_name}HOST.key",
    require     => File["${base_dir}/${base_name}HOST.cnf"],
  }

  # what we should be doing if openssl puppet lib supported it
  #x509_cert { "${base_dir}/${base_name}HOST.crt":
  #  ensure      => $ensure,
  #  template    => "${base_dir}/${base_name}CA.cnf",
  #  private_key => "${base_dir}/${base_name}CA.key",
  #  days        => $days,
  #  password    => $password,
  #  force       => $force,
  #  require     => [
  #    File["${base_dir}/${base_name}HOST.cnf"],
  #    File["${base_dir}/${base_name}CA.cnf"],
  #    File["${base_dir}/${base_name}CA.crt"],
  #    File["${base_dir}/${base_name}CA.key"],
  #  ],
  #}

  # instead of the thing above, do this:
  # hack this because I don't give a crap for self-signed cert code to be doing it "the right way"
  exec { "${base_dir}/${base_name}HOST.crt":
    command => "openssl x509 -req -in ${base_dir}/${base_name}HOST.csr -CA ${base_dir}/${base_name}CA.crt -CAkey ${base_dir}/${base_name}CA.key -CAcreateserial -out ${base_dir}/${base_name}HOST.crt -days 365",
    creates => "${base_dir}/${base_name}HOST.crt",
    require => [
      File["${base_dir}/${base_name}HOST.cnf"],
      File["${base_dir}/${base_name}CA.cnf"],
      File["${base_dir}/${base_name}CA.crt"],
      File["${base_dir}/${base_name}CA.key"],
    ],
  }

  # Set owner of all files
  file {
    "${base_dir}/${base_name}HOST.key":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => '0640',
      require => Ssl_pkey["${base_dir}/${base_name}HOST.key"];

    "${base_dir}/${base_name}HOST.crt":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      require => Exec["${base_dir}/${base_name}HOST.crt"];

    "${base_dir}/${base_name}HOST.csr":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      require => X509_request["${base_dir}/${base_name}HOST.csr"];
  }
}