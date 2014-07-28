define uber85::daemon (
  $user = 'uber',
  $group = 'uber',
  $ensure = present,
  $python_cmd = undef,
  $uber_path = undef,
) {
  supervisor::program { $name :
    ensure        => $ensure,
    enable        => true,
    command       => "${python_cmd} uber/run_server.py",
    directory     => $uber_path,
    # environment => 'NODE_ENV=testing',
    user          => $user,
    group         => $group,
    logdir_mode   => '0770',
  }
}
