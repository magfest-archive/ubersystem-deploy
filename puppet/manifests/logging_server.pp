# this runs on a centralized server,
# collects log information from all the individual nodes,
# and compiles it together into a central system for searching and storage

class logging_centralized_server {
  $logstash_configs = hiera_hash('logstash_configs', {})
  create_resources('logstash::configfile', $logstash_configs)

  $elastisearch_instances = hiera_hash('elastisearch_instances', {})
  create_resources('elasticsearch::instance', $elastisearch_instances)
}