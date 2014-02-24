# Class: activemq
#
# This module manages the ActiveMQ messaging middleware.
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   Class['java']
#
# Sample Usage:
#
# node default {
#   class { 'activemq': }
# }
#
# To supply your own configuration file:
#
# node default {
#   class { 'activemq':
#     server_config => template('site/activemq.xml.erb'),
#   }
# }
#
class activemq(
  $version        = 'present',
  $ensure         = 'running',
  $webconsole     = true,
  $server_config  = 'UNSET',
  $wrapper_config = 'UNSET',
  $credentials    = 'UNSET',
  $jetty_config   = 'UNSET',
  $broker_name    = 'localhost'
) {

  validate_re($ensure, '^running$|^stopped$')
  validate_re($version, '^present$|^latest$|^[._0-9a-zA-Z:-]+$')
  validate_re($broker_name, '^[._0-9a-zA-Z:-]+$')
  validate_bool($webconsole)

  $version_real = $version
  $ensure_real  = $ensure
  $webconsole_real = $webconsole

  # Since this is a template, it should come _after_ all variables are set for
  # this class.
  $server_config_real = $server_config ? {
    'UNSET' => template("${module_name}/activemq.xml.erb"),
    default => $server_config,
  }

  $wrapper_config_real = $wrapper_config ? {
    'UNSET' => template("${module_name}/activemq-wrapper.conf.erb"),
    default => $wrapper_config,
  }

  $credentials_real = $credentials ? {
    'UNSET' => template("${module_name}/credentials.properties.erb"),
    default => $credentials,
  }

  $jetty_config_real = $jetty_config ? {
    'UNSET' => template("${module_name}/jetty.xml.erb"),
    default => $jetty_config,
  }

  # Anchors for containing the implementation class
  anchor { 'activemq::begin':
    before => Class['activemq::packages'],
    notify => Class['activemq::service'],
  }

  class { 'activemq::packages':
    version => $version_real,
    notify  => Class['activemq::service'],
  }

  #If the java package is upgraded make sure activemq restarts
  Package['java'] ~> Class['activemq::service']

  class { 'activemq::config':
    server_config  => $server_config_real,
    wrapper_config => $wrapper_config_real,
    credentials    => $credentials_real,
    jetty_config   => $jetty_config_real,
    require        => Class['activemq::packages'],
    notify         => Class['activemq::service'],
  }

  class { 'activemq::service':
    ensure => $ensure_real,
  }

  anchor { 'activemq::end':
    require => Class['activemq::service'],
  }

}

