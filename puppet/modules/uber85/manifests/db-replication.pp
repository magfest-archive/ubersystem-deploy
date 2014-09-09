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
    database    => $dbname,
    user        => $username,
    address     => $name,
    auth_method => 'md5',
  }

  # open this port on the firewall for this IP
  ufw::allow { "allow postgres from $name":
    from  => "$name",
    proto => 'tcp',
    port  => 5432,
  }
}

define uber85::db-replication-master (
  $dbname,
  $replication_user = 'replicator',
  $replication_password,
  $slave_ips,
) {
  postgresql::server::role { $replication_user:
    password_hash => postgresql_password($replication_user, ''),
    replication   => true
  }

  postgresql::server::config_entry { 
    'listen_address':       value => "'*'";
    'wal_level':            value => 'hot_standby';
    'max_wal_senders':      value => '3';
    'checkpoint_segments':  value => '8';
    'wal_keep_segments':    value => '8';
  }

  uber85::allow-replication-from-ip { $slave_ips:
    dbname           => $dbname,
    replication_user => $replication_user,
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
    owner  => "postgres",
    group  => "postgres",
    mode   => 700,
    mode    => 600,
    content => template('uber85/recovery.conf.erb'),
    notify  => File["${uber_db_util_path}/pg-start-replication.sh"],
  }

  file { "${uber_db_util_path}/pg-start-replication.sh":
    ensure  => present,
    owner  => "postgres",
    group  => "postgres",
    mode   => 700,
    mode    => 700,
    content => template('uber85/pg-start-replication.sh.erb'),
    # notify  => File["${uber_path}/event.conf"],
  }
}
