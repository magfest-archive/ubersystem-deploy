class uber {
  $python_ver = '3'

  $python_cmd = $python_ver ? {
    '2'     => 'python2',
    '3'     => 'python3',
    default => fail("Bad python version: ${python_ver}"),
  }

  class {'uber::install': } -> Class['uber']
}
