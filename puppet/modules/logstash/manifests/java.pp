# == Class: logstash::java
#
# This class exists to install java if its not managed from an other module
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'logstash::java': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
# * Matthias Baur <mailto:matthias.baur@dmc.de>
#
class logstash::java {

  if $logstash::java_package == undef {
    # Default Java package
    case $::operatingsystem {
      'CentOS', 'Fedora', 'Scientific', 'RedHat', 'Amazon', 'OracleLinux': {
        $package = 'java-1.7.0-openjdk'
      }
      'Debian', 'Ubuntu': {
        case $::lsbdistcodename {
          'squeeze': {
            $package = 'openjdk-6-jre-headless'
          }
          default: {
            $package = 'openjdk-7-jre-headless'
          }
        }
      }
      'OpenSuSE': {
        $package = 'java-1_6_0-openjdk'
      }
      'SLES': {
        $package = 'java-1_7_0-ibm'
      }
      default: {
        fail("\"${module_name}\" provides no java package
              for \"${::operatingsystem}\"")
      }
    }
  } else {
    $package = $logstash::java_package
  }

  ## Install the java package unless already specified somewhere else
  if !defined(Package[$package]) {
    package { $package:
      ensure => present
    }
  }
}
