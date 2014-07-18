# == Class: ovirt
#
# This module manages oVirt.
#
# === Parameters
#
# Document parameters here.
#
# [*type*]
#   Specify the type of the oVirt installation (engine or node)
#
# [*adminPassword*]
#   The initial admin password
#
# [*dbUser*]
#   The database user
#
# [*dbPassword*]
#   The database password
#
# [*storageType*]
#   Specify the storage type used by oVirt (nfs, glusterfs, fc and iscsi)
#
# [*organization*]
#   PKI organisational name
#
# [*applicationMode*]
#   Application mode (both, virt, gluster)
#
# [*firewallManager*]
#   Set firewall manager (iptables, firewalld)
#
# === Variables
#
# === Examples
#
#  class { '::ovirt':
#    type => 'engine',
#    adminPassword => 'S3cr3t!'
#  }
#
# === Authors
#
# Author Thomas Bendler <project@bendler-net.de>
#
# === Copyright
#
# Copyright 2013 Thomas Bendler
#
class ovirt (
  $type            = undef,
  $adminPassword   = $ovirt::params::adminPassword,
  $dbUser          = $ovirt::params::dbUser,
  $dbPassword      = $ovirt::params::dbPassword,
  $storageType     = $ovirt::params::storage,
  $organization    = $ovirt::params::organization,
  $applicationMode = $ovirt::params::applicationMode,
  $firewallManager = $ovirt::params::firewallManager) inherits ovirt::params {
  # Require class yum to have the relevant repositories in place
  require yum
  require yum::config::ovirt

  # Start workflow
  if $ovirt::params::linux {
    contain ovirt::package
    contain ovirt::config
    contain ovirt::service

    Class['ovirt::package'] ->
    Class['ovirt::config'] ->
    Class['ovirt::service']
  }
}
