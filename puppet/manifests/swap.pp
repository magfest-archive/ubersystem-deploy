class swap {
  # see https://github.com/petems/petems-swap_file
  swap_file::files { 'default':
    ensure   => present,
  }
}