class bundler (
  $provider = 'gem',
  $ensure   = 'present'
) {

  package { "bundler":
    ensure   => $ensure,
    provider => $provider,
  }
}
