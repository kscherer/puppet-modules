# Define: mcollective::plugins::plugin
#
#   Manage the files for MCollective plugins.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#     mcollective::plugins::plugin { 'package':
#       ensure      => present,
#       type        => 'agent',
#       ddl         => true,
#       application => false,
#     }
#
define mcollective::plugins::plugin(
  $type,
  $ensure      = present,
  $ddl         = false,
  $application = false,
  $recurse     = false,
  $plugin_base = $mcollective::params::plugin_base,
  $module_source = 'puppet:///modules/mcollective/plugins'
) {

  include mcollective::params

  File {
    owner => '0',
    group => '0',
    mode  => '0644',
  }

  if $plugin_base == '' {
    $plugin_base_real = $mcollective::params::plugin_base
  } else {
    $plugin_base_real = $plugin_base
  }

  file { "${plugin_base_real}/${type}/${name}.rb":
    ensure => $ensure,
    source => "${module_source}/${type}/${name}.rb",
    notify => Class['mcollective::server::service'],
  }

  if $ddl {
    file { "${plugin_base_real}/${type}/${name}.ddl":
      ensure => $ensure,
      source => "${module_source}/${type}/${name}.ddl",
    }
  }

  if $application {
    file { "${plugin_base_real}/application/${name}.rb":
      ensure => $ensure,
      source => "${module_source}/application/${name}.rb",
    }
  }
  if $recurse {
    file { "${plugin_base_real}/${type}/${name}":
      ensure  => directory,
      recurse => true,
      purge   => true,
      source  => "${module_source}/${type}/${name}",
    }
  }
}
