note to puppet devs

you can add files in this directory and they will be accessible like this:

file { "/tmp/README.txt":
  source => "puppet:///files/README.txt"
}

note that puppet must be passed a --fileserverconfig (which we're doing) if running in masterless mode (which is how we're doing it as of 11/6/14)