# this runs on a centralized server,
# collects log information from all the individual nodes,
# and compiles it together into a central system for searching and storage

class site::logging_server {
  include 'logstash'
  include 'kibana3'

  ufw::allow { 'allow-logstash':
    port => 9200,
  }

  ufw::allow { 'allow-logstash':
    port => 5601,
  }

  $logstash_configs = hiera_hash('logstash_configs', {})
  create_resources('logstash::configfile', $logstash_configs)

  $logstash_config_lumberjacks = hiera_hash('logstash_config_lumberjacks', {})
  create_resources('logstash::configfile_lumberjack', $logstash_config_lumberjacks)

  $logstash_patternfiles = hiera_hash('logstash_patternfiles', {})
  create_resources('logstash::patternfile', $logstash_patternfiles)

  $elastisearch_instances = hiera_hash('elastisearch_instances', {})
  create_resources('elasticsearch::instance', $elastisearch_instances)
}

# based on logstash::configfile
# we are overriding this only because we need to pass in values to the template file.
# (lumberjack protocol = logstash_forwarder)
define logstash::configfile_lumberjack (
  $ssl_key,
  $ssl_certificate,
  $content = undef,
  $source = undef,
  $order = 10,
  $template = undef,
) {

  if ($template != undef ) {
    $config_content = template($template)
  }
  elsif ($content != undef) {
    $config_content = $content
  }

  file_fragment { $name:
    tag     => "LS_CONFIG_${::fqdn}",
    content => $config_content,
    source  => $source,
    order   => $order,
    before  => [ File_concat['ls-config'] ]
  }
}