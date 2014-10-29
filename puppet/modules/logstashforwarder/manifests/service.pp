# == Class: logstashforwarder::service
#
# This class exists to
# 1. Provide seperation between service creation and other aspects of the module
# 2. Provide a basis for future enhancements involving multiple running instances
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#

# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
# Editor Ryan O'Keeffe

class logstashforwarder::service {

  $fullconfig = "${logstashforwarder::configdir}/${logstashforwarder::config}" 
  $cpuprofile = $logstashforwarder::cpuprofile
  $idle_flush_time = $logstashforwarder::idle_flush_time
  $log_to_syslog    = $logstashforwarder::log_to_syslog
  $spool_size       = $logstashforwarder::spool_size
  $run_as_service   = $logstashforwarder::run_as_service          
  $ensure = $logstashforwarder::ensure  
  $installdir = $logstashforwarder::installdir

  validate_bool($run_as_service)

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  if ($run_as_service == true ) {
    # Setup init file if running as a service
    $notify_logstashforwarder = $logstashforwarder::restart_on_change ? {
       true  => Service["logstash-forwarder"],
       false => undef,
    }

    file { '/etc/init.d/logstash-forwarder' :
      ensure  => $ensure,
      mode    => '0755',
      content => template("${module_name}/etc/init.d/logstash-forwarder.erb"),
      notify  => $notify_logstashforwarder
    }

    #### Service management

    # set params: in operation
    if $logstashforwarder::ensure == 'present' {

      case $logstashforwarder::status {
        # make sure service is currently running, start it on boot
        'enabled': {
          $service_ensure = 'running'
          $service_enable = true
        }
        # make sure service is currently stopped, do not start it on boot
        'disabled': {
          $service_ensure = 'stopped'
          $service_enable = false
        }
        # make sure service is currently running, do not start it on boot
        'running': {
          $service_ensure = 'running'
          $service_enable = false
        }
        # do not start service on boot, do not care whether currently running or not
        'unmanaged': {
          $service_ensure = undef
          $service_enable = false
        }
        # unknown status
        # note: don't forget to update the parameter check in init.pp if you
        #       add a new or change an existing status.
        default: {
          fail("\"${logstashforwarder::status}\" is an unknown service status value")
        }
      }

    # set params: removal
    } else {

      # make sure the service is stopped and disabled (the removal itself will be
      # done by package.pp)
      $service_ensure = 'stopped'
      $service_enable = false
    }
    service { "logstash-forwarder":
            ensure     => $service_ensure,
            enable     => $service_enable,
            name       => $logstashforwarder::params::service_name,
            hasstatus  => $logstashforwarder::params::service_hasstatus,
            hasrestart => $logstashforwarder::params::service_hasrestart,
            pattern    => $logstashforwarder::params::service_pattern,
            require    => File['/etc/init.d/logstash-forwarder'],
    }
  } 
  else {
    $notify_logstashforwarder = undef
  }
}
