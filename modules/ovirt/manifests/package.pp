# Class: ovirt::package
#
# This module contain the package configuration for oVirt
#
# Parameters:   This module has no parameters
#
# Actions:      This module has no actions
#
# Requires:     This module has no requirements
#
# Sample Usage:
#
class ovirt::package {
  if $ovirt::type == 'engine' {
    package { $ovirt::params::packageEngine: ensure => installed; }
  }
  if $ovirt::type == 'node' {
    package { $ovirt::params::packageNode: ensure => installed; }
  }
}
