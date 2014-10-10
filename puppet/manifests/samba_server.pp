class samba_server {

  # HACK: we're not using samba_server in production ever,
  # so just disable the firewall outright.
  ufw::allow { "everything":  }

class { '::samba::server':
  workgroup            => 'VAGRANT',
  server_string        => 'Vagrant SMB server',
  netbios_name         => 'V01',
  interfaces           => [ 'lo', 'eth0' ],
  local_master         => 'yes',
  map_to_guest         => 'Bad User',
  os_level             => '50',
  preferred_master     => 'yes',
  #extra_global_options => [
  #  'printing = BSD',
  #  'printcap name = /dev/null',
  #],
  shares => {
    'uber' => [
      'comment = Ubersystem Vagrant Dev',
      'path = /usr/local/uber',
      'browseable = yes',
      'writable = yes',
      'guest ok = yes',
      'available = yes',
    ],
  },
  selinux_enable_home_dirs => true,
}

}
