class uber85::python {
  class { '::python':
    # ensure   => present,
    version    => $uber85::python_ver,
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => false,
  }
}
