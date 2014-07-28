class uber::python {
  class { '::python':
    # ensure   => present,
    version    => $uber::python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
  }
}
