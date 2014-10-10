import 'uber_server.pp'
import 'samba_server.pp'

node default {
}

# install ubersystem + samba on vagrant nodes
node 'vagrant-ubuntu-trusty-32' inherits default {
  include uber_server
  include samba_server
}
