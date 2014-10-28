# this runs on each node and transmits log information to the central server

class logstashforwarders {
  $logstashforwarder_files = hiera_hash('logstashforwarder_files', undef)
  create_resources('logstashforwarder::file', $logstashforwarder_files)
}