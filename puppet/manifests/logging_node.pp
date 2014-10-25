# this runs on each node and transmits log information to the central server

class logging_node {
  class { 'logstashforwarder':
    manage_repo  => true
  }
}
