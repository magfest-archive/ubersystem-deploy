# == Class: logstashforwarder
#
# This class is able to install or remove logstash-forwarder on a node.
# It manages the status of the related service.
#
# [Add description - What does this module do on a node?] FIXME/TODO
#
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
#   Boolean. If set to <tt>true</tt>, any managed package gets upgraded
#   on each Puppet run when the package provider is able to find a newer
#   version than the present one. The exact behavior is provider dependent.
#   Q.v.:
#   * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
#   * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   Defaults to <tt>false</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*version*]
#   String to set the specific version you want to install.
#   Defaults to <tt>false</tt>.
#
# [*configdir*]
#   Path where the configuration files will be placed.
#   Defaults to <tt>/etc/logstash-forwarder</tt>
#
# [*config*]
#   The name of the config file to create
#   Defaults to <tt>logstash-forwarder.conf</tt>
#
# [*cpuprofile*]
#   write cpu profile to file
#
# [*idle_flush_time*]
#   Maximum time to wait for a full spool before flushing anyway
#
# [*log_to_syslog*]
#   Log to syslog instead of stdout
#
# [*spool_size*]
#   Maximum number of events to spool before a flush is forced.
#
# [*servers*]
#   List of Host names or IP addresses of Logstash instances to connect to
#
# [*ssl_ca_file*]
#   File to use for the SSL CA
#
# [*ssl_key*]
#   File to use for your host's SSL key
#
# [*ssl_certificate*]
#   File to use for your host's SSL cert
#
#
#
# The default values for the parameters are set in logstash-forwarder::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
#
# === Examples
#
# * Installation, make sure service is running and will be started at boot time:
#     class { 'logstashforwarder': }
#
# * Removal/decommissioning:
#     class { 'logstashforwarder':
#       ensure => 'absent',
#     }
#
# * Install everything but disable service(s) afterwards
#     class { 'logstashforwarder':
#       status => 'disabled',
#     }
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
# Editor: Kayla Green <mailto:kaylagreen@gmail.com>
# Editor: Ryan O'Keeeffe

class logstashforwarder(
  $config = $logstashforwarder::params::config,
  $configdir = $logstashforwarder::params::configdir,
  $ensure            = $logstashforwarder::params::ensure,
  $autoupgrade       = $logstashforwarder::params::autoupgrade,
  $status            = $logstashforwarder::params::status,
  $restart_on_change = $logstashforwarder::params::restart_on_change,
  $manage_repo       = false,
  $version           = false,
  $run_as_service     = true,
  $servers,
  $ssl_ca_path,
  $ssl_certificate         = undef,
  $ssl_key          = undef,
  $cpuprofile       = undef,
  $idle_flush_time  = undef,
  $spool_size       = 1024,
  $log_to_syslog    = true,
) inherits logstashforwarder::params {

  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  validate_array($servers)
  validate_string($ssl_ca_path)

  if ($ssl_key != undef){
        validate_string($ssl_key)
  }
  if ($ssl_certificate != undef){
        validate_string($ssl_certificate)
  }
  if ($cpuprofile != undef) {
        validate_string($cpuprofile)
  }

  if ($log_to_syslog != '') {
        validate_bool($log_to_syslog)
  }

  if ($idle_flush_time != '') {
        validate_string($idle_flush_time)
  }

  if ! is_numeric($spool_size) {
      fail("\"${spool_size}\" is not a valid spool-size parameter value")
  }

  # autoupgrade
  validate_bool($autoupgrade)

  # service status
  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  #### Manage Actions
  if ($ensure == 'present') {
        anchor {'logstashforwarder::begin':
            before  => Class['logstashforwarder::config'],
            notify  => Class['logstashforwarder::service'],
        }
        class {'logstashforwarder::config':
            notify  => Class['logstashforwarder::service'],
        }
        class {'logstashforwarder::package':
            require => Class['logstashforwarder::config'],
            notify  => Class['logstashforwarder::service'],
        }
        class {'logstashforwarder::service':
            require => Class['logstashforwarder::config'],
        }

        if ($manage_repo == true) {
          # Set up repositories
          class { 'logstashforwarder::repo': }

          # Ensure that we set up the repositories before trying to install
          # the packages
          Anchor['logstashforwarder::begin']
          -> Class['logstashforwarder::repo']
          -> Class['logstashforwarder::package']
        }

        anchor { 'logstashforwarder::end': 
            require => Class['logstashforwarder::service']
        }
  }
  else {
        anchor { 'logstashforwarder::begin': 
            before  => Class['logstashforwarder::service'],
            notify  => Class['logstashforwarder::config'],
        }
        class {'logstashforwarder::service':
            notify  => Class['logstashforwarder::package'],
        }
        class {'logstashforwarder::package':
            require => Class['logstashforwarder::service'],
            notify  => Class['logstashforwarder::config'],
        }
        class {'logstashforwarder::config':
            require => Class['logstashforwarder::package'],
        }
        anchor {'logstashforwarder::end': 
            require => Class['logstashforwarder::config'],
        }
  }
}
