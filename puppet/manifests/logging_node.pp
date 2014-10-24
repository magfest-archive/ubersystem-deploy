class logging_node {
  class { 'logstash':
    install_contrib => true,
    manage_repo => true,
    repo_version => '1.4',
  }
}