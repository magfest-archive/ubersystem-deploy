import 'uber_server.pp'

node default {
}

# install ubersystem on vagrant nodes
node 'vagrant-ubuntu-trusty-32' inherits default {
  include uber_server
}
