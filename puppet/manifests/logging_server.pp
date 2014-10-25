# this runs on a centralized server,
# collects log information from all the individual nodes,
# and compiles it together into a central system for searching and storage

class logging_centralized_server {
  $logstash_servers = hiera_hash('logstash_servers', {})
  create_resources('logstash_server', $logstash_servers)

  $eliastisearch_servers = hiera_hash('eliastisearch_servers', {})
  create_resources('eliastisearch_server', $eliastisearch_servers)
}

class logstash_server () {
  class { 'logstash':
    install_contrib => true,
    manage_repo => true,
    repo_version => '1.4',
  }
}

class elastisearch_server () {
  class { 'elasticsearch':
    manage_repo  => true,
    repo_version => '1.3',
  }

  elasticsearch::instance { 'es-01': }
}