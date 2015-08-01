class roles {

}

class roles::uber_server () inherits roles {
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => 'localhost',
    manage_firewall            => true,
  }

  include uber
  include uber::rams_app_stack
}