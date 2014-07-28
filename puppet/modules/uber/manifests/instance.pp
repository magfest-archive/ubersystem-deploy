define uber::instance
(
  $uber_path = '/usr/local/uber',
  $git_repo = 'https://github.com/EliAndrewC/magfest',
  $git_branch = 'master',
  $uber_user = 'uber',
  $uber_group = 'apps',

  $sideboard_debug_enabled = false,

  $db_host = 'localhost',
  $db_port = '5432',
  $db_user = 'm13',
  $db_pass = 'm13',
  $db_name = 'm13',

  $socket_port = '4321',
  $socket_host = '0.0.0.0',
  $hostname = '', # defaults to hostname of the box
  $url_prefix = 'magfest',

  $open_firewall_port = false, # if using apache/nginx, you dont want this.

  # config file settings only below
  $theme = 'magfest',
  $event_name = 'MAGFest',
  $organization_name = 'MAGFest',
  $year = 1,
  $show_affiliates_and_extras = True,
  $group_reg_available = True,
  $group_reg_open = True,
  $send_emails = False,
  $aws_access_key = '',
  $aws_secret_key = '',
  $stripe_secret_key = '',
  $stripe_public_key = '',
  $dev_box = False,
  $supporter_badge_type_enabled = True,
  $prereg_opening,
  $prereg_takedown,
  $uber_takedown,
  $epoch,
  $eschaton,
  $email_categories_allowed_to_send = [ 'all' ],
  $prereg_price = 45,
  $at_door_price = 60,
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

  vcsrepo { $uber_path:
    ensure   => latest,
    owner    => $uber_user,
    group    => $uber_group,
    provider => git,
    source   => $git_repo,
    revision => $git_branch,
    notify   => File["${uber_path}/production.conf"],
  }

  file { "${uber_path}/production.conf":
    ensure  => present,
    mode    => 660,
    content => template('uber/production.conf.erb'),
    notify   => File["${uber_path}/event.conf"],
  }

  file { "${uber_path}/event.conf":
    ensure  => present,
    mode    => 660,
    content => template('uber/event.conf.erb'),
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
    notify  => Exec["uber_init_db_${name}"],
  }

  # note: init_db.py will only init the DB if it doesn't already exist
  # i.e. there's no chance we'll clobber production data accidentally.
  exec { "uber_init_db_${name}" :
    command     => "${venv_python} uber/init_db.py",
    cwd         => "${uber_path}",
    refreshonly => true,
    notify      => Exec["setup_owner_$name"],
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
    hostname => $hostname,
    # notify   => Nginx::Resource::Location["${hostname}-${name}"],
  }

  $proxy_url = "http://127.0.0.1:${socket_port}/${url_prefix}/"

  nginx::resource::location { "${hostname}-${name}":
    ensure   => present,
    proxy    => $proxy_url,
    location => "/${url_prefix}/",
    vhost    => $hostname,
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
