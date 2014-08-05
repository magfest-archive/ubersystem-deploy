define uber::plugins
(
  $plugins,
  $plugins_dir,
  $user,
  $group,
)
{
  $plugin_defaults = {
    'user'        => $user,
    'group'       => $group,
    'plugins_dir' => $plugins_dir,
  }
  create_resources(uber::plugin, $plugins, $plugin_defaults)
  # notify { "SUPGIRL2 ${plugins}": }
}

# sideboard can install a bunch of plugins which each pull their own
# git repos
define uber::plugin 
(
  # $repo_install_path = $name,
  $plugins_dir,
  $user,
  $group,
  $git_repo,
  $git_branch,
)
{
  # notify { "SUPGIRL3 plugins_dir = ${plugins_dir}, name = ${name}, repo_info = ${git_repo}": }
  uber::plugin_repo { "${plugins_dir}/${name}":
    user       => $user,
    group      => $group,
    git_repo   => $git_repo,
    git_branch => $git_branch,
  }
}

define uber::plugin_repo
(
  # path = $name
  $user,
  $group,
  $git_repo,
  $git_branch,
)
{
  vcsrepo { $name:
    ensure   => latest,
    owner    => $user,
    group    => $group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch
  }
}

define uber::instance
(
  $uber_path = '/usr/local/uber',
  $sideboard_repo,
  $sideboard_branch = 'master',
  $uber_user = 'uber',
  $uber_group = 'apps',

  $sideboard_debug_enabled = false,

  $db_host = 'localhost',
  $db_port = '5432',
  $db_user = 'm13',
  $db_pass = 'm13',
  $db_name = 'm13',
  
  $sideboard_plugins = {},

  $socket_port = '4321',
  $socket_host = '0.0.0.0',
  $hostname = '', # defaults to hostname of the box
  $url_prefix = 'magfest',

  $open_firewall_port = false, # if using apache/nginx, you dont want this.

  # config file settings only below
  $event_name = 'MAGFest',
  $organization_name = 'MAGFest',
  $year = 1,
  #$show_affiliates_and_extras = True,
  #$group_reg_available = True,
  #$group_reg_open = True,
  $send_emails = False,
  $aws_access_key = '',
  $aws_secret_key = '',
  $stripe_secret_key = '',
  $stripe_public_key = '',
  $dev_box = False,
  #$supporter_badge_type_enabled = True,
  #$prereg_opening,
  #$prereg_takedown,
  #$uber_takedown,
  #$epoch,
  #$eschaton,
  #$prereg_price = 45,
  #$at_door_price = 60,
  $at_the_con = False,
  $max_badge_sales = 9999999,
) {

  $hostname_to_use = $hostname ? {
    ''      => $fqdn,
    default => $hostname,
  }

  $venv_path = "${uber_path}/env"
  $venv_bin = "${venv_path}/bin"
  $venv_python = "${venv_bin}/python"

  # TODO: don't hardcode 'python 3.4' in here, set it up in ::uber
  $venv_site_pkgs_path = "${venv_path}/lib/python3.4/site-packages"

  uber::user_group { "users and groups ${name}":
    user   => $uber_user,
    group  => $uber_group,
    notify => Uber::Db["uber_db_${name}"]
  }

  uber::db { "uber_db_${name}":
    user   => $db_user,
    pass   => $db_pass,
    dbname => $db_name,
    notify => Exec["stop_daemon_${name}"]
  }

  exec { "stop_daemon_${name}" :
    command     => "/usr/local/bin/supervisorctl stop ${name}",
    notify   => [ Class['uber::install'], Vcsrepo[$uber_path] ]
  }

  # sideboard
  vcsrepo { $uber_path:
    ensure   => latest,
    owner    => $uber_user,
    group    => $uber_group,
    provider => git,
    source   => $sideboard_repo,
    revision => $sideboard_branch,
    notify  => File["${uber_path}/plugins/"],
  }

  file { [ "${uber_path}/plugins/" ]:
    ensure => "directory",
    notify => Uber::Plugins["${name}_plugins"],
  }

  # TODO development.ini for each plugin

  uber::plugins { "${name}_plugins":
    plugins     => $sideboard_plugins,
    plugins_dir => "${uber_path}/plugins",
    user        => $uber_user,
    group       => $uber_group,
    notify      => File["${uber_path}/development.ini"],
  }

  # sideboard's development.ini
  # note: plugins can also have their own development.ini,
  # we need to take that into account.
  file { "${uber_path}/development.ini":
    ensure  => present,
    mode    => 660,
    content => template('uber/sb-development.ini.erb'),
    notify  => Exec["uber_virtualenv_${name}"]
  }

  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { "uber_virtualenv_${name}":
    command => "${uber::python_cmd} -m venv ${venv_path} --without-pip",
    cwd     => $uber_path,
    path    => '/usr/bin',
    creates => "${venv_path}",
    notify  => Exec["uber_distribute_setup_${name}"],
  }

  exec { "uber_distribute_setup_${name}" :
    command => "${venv_python} distribute_setup.py",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/setuptools.pth",
    notify  => Exec["uber_setup_${name}"],
  }

  exec { "uber_setup_${name}" :
    command => "${venv_python} setup.py develop",
    cwd     => "${uber_path}",
    creates => "${venv_site_pkgs_path}/uber.egg-link",
    notify  => Exec["setup_owner_$name"],
  }

  # setup owner
  exec { "setup_owner_$name":
    command => "/bin/chown -R ${uber_user}:${uber_group} ${uber_path}",
    notify  => Exec[ "setup_perms_$name" ],
  }

  # setup permissions
  $mode = 'o-rwx,g-w,u+rw'
  exec { "setup_perms_$name":
    command => "/bin/chmod -R $mode ${uber_path}",
    notify  => Uber::Daemon["${name}_daemon"],
  }   

  # run as a daemon with supervisor
  uber::daemon { "${name}_daemon": 
    user       => $uber_user,
    group      => $uber_group,
    python_cmd => $venv_python,
    uber_path  => $uber_path,
    notify     => Uber::Firewall["${name}_firewall"],
  }

  uber::firewall { "${name}_firewall":
    socket_port        => $socket_port,
    open_firewall_port => $open_firewall_port,
    notify             => Uber::Vhost[$name],
  }

  uber::vhost { $name:
    hostname => $hostname_to_use,
    # notify   => Nginx::Resource::Location["${hostname}-${name}"],
  }

  $proxy_url = "http://127.0.0.1:${socket_port}/${url_prefix}/"

  nginx::resource::location { "${hostname_to_use}-${name}":
    ensure   => present,
    proxy    => $proxy_url,
    location => "/${url_prefix}/",
    vhost    => $hostname_to_use,
    ssl      => true,
  }
}

define uber::vhost (
  $hostname,
) {
  if ! defined(Nginx::Resource::Vhost[$hostname]) {
    nginx::resource::vhost { $hostname:
      www_root    => '/var/www/',
      rewrite_to_https => true,
      ssl              => true,
      ssl_cert         => 'puppet:///modules/uber/magfest.org.crt-bundle',
      ssl_key          => 'puppet:///modules/uber/magfest.org.key',
    }
  }
}

define uber::firewall (
  $socket_port,
  $open_firewall_port = false,
) {
  if $open_firewall_port {
    ufw::allow { $title:
      port => $socket_port,
    }
  }
}
