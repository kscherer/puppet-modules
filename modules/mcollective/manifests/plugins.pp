# Class: mcollective::plugins
#
#   This class deploys the default set of MCollective
#   plugins
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   Class['mcollective']
#   Class['mcollective::service']
#
# Sample Usage:
#
#   This class is intended to be declared in the mcollective class.
#
class mcollective::plugins(
  $plugin_base = $mcollective::params::plugin_base,
  $plugin_subs = $mcollective::params::plugin_subs,
  $enable_registration_collection = false
) inherits mcollective::params {

  File {
    owner => '0',
    group => '0',
    mode  => '0644',
  }

  # $plugin_base and $plugin_subs are meant to be arrays.
  file { $plugin_base:
    ensure  => directory,
    replace => false,
    require => Class['mcollective::server::package'],
  }
  file { $plugin_subs:
    ensure => directory,
    notify => Class['mcollective::server::service'],
  }

  if $enable_registration_collection {
    $registration_agent_ensure = present
  } else {
    $registration_agent_ensure = absent
  }

  mcollective::plugins::plugin { 'registration':
    ensure      => $registration_agent_ensure,
    type        => 'agent',
    ddl         => false,
    application => false,
  }
  mcollective::plugins::plugin { 'facter_facts':
    ensure => present,
    type   => 'facts',
  }
  mcollective::plugins::plugin { 'yaml_facts':
    ensure => present,
    type   => 'facts',
  }
  mcollective::plugins::plugin { 'service':
    ensure      => absent,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'package':
    ensure      => present,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'meta':
    ensure      => present,
    type        => 'registration',
    ddl         => false,
    application => false,
  }
  # Add the NRPE Agent by default
  mcollective::plugins::plugin { 'nrpe':
    ensure      => present,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'puppet':
    ensure      => present,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'puppetd':
    ensure      => present,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'puppetral':
    ensure      => absent,
    type        => 'agent',
    ddl         => true,
    application => false,
  }
  mcollective::plugins::plugin { 'shellcmd':
    ensure      => absent,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'shell':
    ensure      => present,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'etc_facts':
    ensure      => absent,
    type        => 'agent',
    ddl         => true,
    application => true,
  }
  mcollective::plugins::plugin { 'boolean_summary':
    ensure      => present,
    type        => 'aggregate',
    ddl         => true,
  }
  mcollective::plugins::plugin { ['puppet_data', 'resource_data']:
    ensure      => present,
    type        => 'data',
    ddl         => true,
  }
  mcollective::plugins::plugin {
    [ 'puppet_resource_validator', 'puppet_server_address_validator',
      'puppet_tags_validator', 'puppet_variable_validator']:
      ensure      => present,
      type        => 'validator',
      ddl         => true,
  }
  mcollective::plugins::plugin { 'puppet_agent_mgr':
    ensure      => present,
    type        => 'util',
    recurse     => true,
  }
}
