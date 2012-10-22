# Class: activemq::config
#
#   class description goes here.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::config (
  $server_config  = 'UNSET',
  $wrapper_config = 'UNSET',
  $credentials    = 'UNSET',
  $path = '/etc/activemq/'
) {

  if $server_config == 'UNSET' {
    fail('ActiveMQ server configuration not set.')
  }

  if $wrapper_config == 'UNSET' {
    fail('ActiveMQ wrapper configuration not set.')
  }

  if $credentials == 'UNSET' {
    fail('ActiveMQ credentials are not set.')
  }

  validate_re($path, '^/')
  $path_real = $path

  # Resource defaults
  File {
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0644',
    notify  => Service['activemq'],
    require => Package['activemq'],
  }

  # The configuration file itself.
  file { 'activemq.xml':
    ensure  => file,
    path    => "${path_real}/activemq.xml",
    content => $server_config,
  }
  file { 'activemq-wrapper.conf':
    ensure  => file,
    path    => "${path_real}/activemq-wrapper.conf",
    content => $wrapper_config,
  }
  file { 'credentials.properties':
    ensure  => file,
    path    => "${path_real}/credentials.properties",
    content => $credentials,
  }
}
