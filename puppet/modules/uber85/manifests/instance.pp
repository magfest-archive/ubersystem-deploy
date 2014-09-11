define uber85::instance
(
  $uber_path = '/usr/local/uber',
  $git_repo = 'https://github.com/EliAndrewC/magfest',
  $git_branch = 'master',
  $uber_user = 'uber',
  $uber_group = 'apps',

  $ssl_crt_bundle = 'puppet:///modules/uber85/magfest.org.crt-bundle',
  $ssl_crt_key = 'puppet:///modules/uber85/magfest.org.key',

  $db_host = 'localhost',
  $db_user = 'm13',
  $db_pass = 'm13',
  $db_name = 'm13',

  # DB replication common mode settings
  $db_replication_mode = 'none', # none, master, or slave
  $db_replication_user = 'replicator',
  $db_replication_password = '',

  # DB replication slave settings ONLY
  $db_replication_master_ip = '', # IP of the master server
  $uber_db_util_path = '/usr/local/uberdbutil',

  # DB replication master settings ONLY
  $slave_ips = [],

  $django_debug = False,

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
  $hide_schedule = True,
  $custom_badges_really_ordered = False,
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

  uber85::user_group { "users and groups ${name}":
    user   => $uber_user,
    group  => $uber_group,
    notify => Uber85::Db["uber_db_${name}"]
  }

  uber85::db { "uber_db_${name}":
    user             => $db_user,
    pass             => $db_pass,
    dbname           => $db_name,
    db_replication_mode => $db_replication_mode,
    notify           => Exec["stop_daemon_${name}"]
  }

  exec { "stop_daemon_${name}" :
    command     => "/usr/local/bin/supervisorctl stop ${name}",
    notify   => [ Class['uber85::install'], Vcsrepo[$uber_path] ]
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
    content => template('uber85/production.conf.erb'),
    notify   => File["${uber_path}/event.conf"],
  }

  file { "${uber_path}/event.conf":
    ensure  => present,
    mode    => 660,
    content => template('uber85/event.conf.erb'),
    notify  => Exec["uber_virtualenv_${name}"]
  }


  # seems puppet's virtualenv support is broken for python3, so roll our own
  exec { "uber_virtualenv_${name}":
    command => "${uber85::python_cmd} -m venv ${venv_path} --without-pip",
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
    notify  => Uber85::Init_db["${name}"],
  }

  uber85::init_db { "${name}":
    venv_python         => $venv_python,
    uber_path           => $uber_path,
    db_replication_mode => $db_replication_mode,
    notify              => Exec["setup_owner_$name"],
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
    #notify  => Uber85::Replication["${name}_replication"],
    notify  => Uber85::Daemon["${name}_daemon"],
  }

  uber85::replication { "${name}_replication":
    db_name                  => $db_name,
    db_replication_mode      => $db_replication_mode,
    db_replication_user      => $db_replication_user,
    db_replication_password  => $db_replication_password,
    db_replication_master_ip => $db_replication_master_ip,
    uber_db_util_path        => $uber_db_util_path,
    slave_ips                => $slave_ips,
    #notify                  => Uber85::Daemon["${name}_daemon"],
    # subscribe                => Postgresql::Server::Db["${db_name}"]
  }

  # run as a daemon with supervisor
  uber85::daemon { "${name}_daemon": 
    user       => $uber_user,
    group      => $uber_group,
    python_cmd => $venv_python,
    uber_path  => $uber_path,
    notify     => Uber85::Firewall["${name}_firewall"],
  }

  uber85::firewall { "${name}_firewall":
    socket_port        => $socket_port,
    open_firewall_port => $open_firewall_port,
    notify             => Uber85::Vhost[$name],
  }

  uber85::vhost { $name:
    hostname       => $hostname,
    ssl_crt_bundle => $ssl_crt_bundle,
    ssl_crt_key    => $ssl_crt_key,
    # notify       => Nginx::Resource::Location["${hostname}-${name}"],
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

define uber85::init_db (
  $venv_python,
  $uber_path,
  $db_replication_mode = 'none',
) {
  # note: init_db.py will only init the DB if it doesn't already exist
  # i.e. there's no chance we'll clobber production data accidentally.
  if $db_replication_mode != 'slave' 
  {
    exec { "uber_init_db_${name}" :
      command     => "${venv_python} uber/init_db.py",
      cwd         => "${uber_path}",
      refreshonly => true,
    }
  }
}

define uber85::replication (
  # DB replication common settings
  $db_name,
  $db_replication_mode, # none, master, or slave
  $db_replication_user,
  $db_replication_password,

  # DB replication slave settings ONLY
  $db_replication_master_ip, # IP of the master server
  $uber_db_util_path,

  # DB replication master settings ONLY
  $slave_ips,
) {
  # setup replication
  if $db_replication_mode == 'master'
  {
    if $db_replication_password == '' {
      fail("can't do database replication without setting a replication passwd")
    }

    uber85::dbreplicationmaster { "${db_name}_replication_master":
      dbname               => $db_name,
      replication_user     => $db_replication_user,
      replication_password => $db_replication_password,
      slave_ips            => $slave_ips,
    }
  }
  if $db_replication_mode == 'slave'
  {
    if $db_replication_password == '' {
      fail("can't do database replication without setting a replication passwd")
    }

    if $db_replication_master_ip == '' {
      fail("can't do DB slave replication without a master IP address")
    }

    uber85::db-replication-slave { "${db_name}_replication_slave":
      dbname               => $db_name,
      replication_user     => $db_replication_user,
      replication_password => $db_replication_password,
      master_ip            => $db_replication_master_ip,
      uber_db_util_path    => $uber_db_util_path,
    }
  }
}


define uber85::vhost (
  $hostname,
  $ssl_crt_bundle,
  $ssl_crt_key,
) {
  if ! defined(Nginx::Resource::Vhost[$hostname]) {
    nginx::resource::vhost { $hostname:
      www_root    => '/var/www/',
      rewrite_to_https => true,
      ssl              => true,
      ssl_cert         => $ssl_crt_bundle,
      ssl_key          => $ssl_crt_key,
    }
  }
}

define uber85::firewall (
  $socket_port,
  $open_firewall_port = false,
) {
  if $open_firewall_port {
    ufw::allow { $title:
      port => $socket_port,
    }
  }
}


# Class uber::db-replication
#
# Handles replication stuff for ubersystem
#
# 

define uber85::allow-replication-from-ip (
  $dbname,
  $username,
) {
  postgresql::server::pg_hba_rule { "rep access for ${name}":
    description => "Open up postgresql for access from ${name}",
    type        => 'hostssl',
    database    => 'replication', #$dbname,
    user        => $username,
    address     => "${name}/32",
    auth_method => 'md5',
  }

  # open this port on the firewall for this IP
  ufw::allow { "allow postgres from $name":
    from  => "$name",
    proto => 'tcp',
    port  => 5432,
  }
}

define uber85::dbreplicationmaster (
  $dbname,
  $replication_user = 'replicator',
  $replication_password,
  $slave_ips,
) {
  postgresql::server::role { $replication_user:
    password_hash => postgresql_password($replication_user, $replication_password),
    replication   => true,
    #notify        => Postgresql::Server::Config_Entry['wal_level'],
    subscribe      => Postgresql::Server::Db["${dbname}"]
  }

  postgresql::server::config_entry { 
     # 'listen_address':       value => "*";
     'wal_level':            value => 'hot_standby';
     'max_wal_senders':      value => '3';
     'checkpoint_segments':  value => '8';
     'wal_keep_segments':    value => '8';
  }

  uber85::allow-replication-from-ip { $slave_ips:
    dbname   => $dbname,
    username => $replication_user,
  }
}

define uber85::db-replication-slave (
  $dbname,
  $replication_user = 'replicator',
  $replication_password,
  $master_ip,
  $uber_db_util_path = '/usr/local/uberdbutil'
) {

  postgresql::server::config_entry { 
    'wal_level':            value => 'hot_standby';
    'max_wal_senders':      value => '3';
    'checkpoint_segments':  value => '8';
    'wal_keep_segments':    value => '8';
    'hot_standby':          value => 'on';
  }

  # a fuller example, including permissions and ownership
  file { "${uber_db_util_path}":
    ensure => "directory",
    owner  => "postgres",
    group  => "postgres",
    mode   => 700,
    notify  => File["${uber_db_util_path}/recovery.conf"],
  }

  file { "${uber_db_util_path}/recovery.conf":
    ensure  => present,
    owner   => "postgres",
    group   => "postgres",
    mode    => 600,
    content => template('uber85/pg-recovery.conf.erb'),
    notify  => File["${uber_db_util_path}/pg-start-replication.sh"],
  }

  file { "${uber_db_util_path}/pg-start-replication.sh":
    ensure   => present,
    owner    => "postgres",
    group    => "postgres",
    mode     => 700,
    content  => template('uber85/pg-start-replication.sh.erb'),
    notify => File["${uber_db_util_path}/sync-to-master.sh"],
  }

  file { "${uber_db_util_path}/sync-to-master.sh":
    ensure   => present,
    owner    => "postgres",
    group    => "postgres",
    mode     => 700,
    content  => template('uber85/pg-sync.sh.erb'),
    # notify => File["${uber_path}/event.conf"],
  }
}
