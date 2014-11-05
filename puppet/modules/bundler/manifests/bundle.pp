define bundler::bundle (
  $source,
  $gems,
  $timeout = 300,
) {
  include bundler

  file { $name:
    content => template('bundler/Gemfile'),
    notify  => Exec["bundle_${name}"]
  }

  exec { "bundle_${name}":
    path        => "/var/lib/gems/1.8/bin",
    command     => "bundle install",
    cwd         => dirname("${name}"),
    refreshonly => true,
    timeout     => $timeout,
  }
}
