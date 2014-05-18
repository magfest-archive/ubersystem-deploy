define uber::server (
  $db_user = 'mag',
  $db_pass = 'mag',
  $db_name = 'mag',
  $uber_path = '/usr/local/uber',
  $git_repo = 'https://github.com/EliAndrewC/magfest',
  $git_branch = 'develop',
  $url_prefix = 'magfest',
  $socket_port = '4321',
  $uber_user = 'uber',
  $uber_group = 'apps', 
)
{
  Class['uber::install'] -> Uber::Server[$title]
}
