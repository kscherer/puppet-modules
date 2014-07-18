# Class: ovirt::service
#
# This module contain the service configuration for oVirt
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class ovirt::service {
  if $ovirt::type == 'engine' {
    service { $ovirt::params::serviceEngine:
      ensure     => running,
      enable     => true,
      name       => $ovirt::params::serviceEngine,
      require    => Package[$ovirt::params::packageEngine];
    }
  }
  if $ovirt::type == 'node' {
    service { $ovirt::params::serviceNode:
      ensure     => running,
      enable     => true,
      name       => $ovirt::params::serviceNode,
      require    => Package[$ovirt::params::packageNode];
    }
  }
}
