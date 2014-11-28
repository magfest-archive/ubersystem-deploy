# puppet-logstashforwarder

A puppet module for managing and configuring logstash-forwarder

https://github.com/elasticsearch/logstash-forwarder/

This module is based upon https://github.com/electrical/puppet-lumberjack and https://github.com/MixMuffins/puppet-lumberjack

This updated module is in the beta stage and although it is tested, not all scenarios may be covered.

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'logstashforwarder': 
       cpuprofile       => '/path/to/write/cpu/profile/to/file',
       idle_flush_time  => '5',
       log_to_syslog    => false,
       spool_size       => '1024',
       servers          => ['listof.hosts:12345', '127.0.0.1:9987'],
       ssl_ca           => '/path/to/ssl/root/certificate',
     }

Removal/decommissioning:

     class { 'logstashforwarder':
       ensure => 'absent',
     }

Install everything but disable service(s) afterwards:

     class { 'logstashforwarder':
       status => 'disabled',
     }

To configure file inputs:

    logstashforwarder::file { 'localhost-syslog':
        paths    => ['/var/log/messages','/var/log/secure','/var/log/*.log/'],
        fields   => { 'type' : 'syslog' }, 
    }
    
    Fields can also be a simple array using a "key, value, key, value" form to prevent the order from getting randomized.  Sub-arrays for values are not supported as of yet:

    logstashforwarder::file { 'localhost-syslog':
        paths    => ['/var/log/messages','/var/log/secure','/var/log/*.log/'],
        fields   => [ 'type', 'syslog', 'tags', 'rhel' ],
}
 
 

## Parameters

Default parameters have been set in the params.pp class file.  Options include config file and directory, package name, install dir (used by the service(s), amoung others.
