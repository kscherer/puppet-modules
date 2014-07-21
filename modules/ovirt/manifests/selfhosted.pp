# == Class: ovirt::selfhosted
#
# The ovirt::selfhosted class installs oVirt Self Hosted Engine.
#
# === Parameters
#
# [*application_mode*]
#   This setting can be used to override the default ovirt application mode of
#   both.  Valid options are both, virt, gluster.
#
# [*storage_type*]
#   This setting can be used to override the default ovirt storage type of nfs.
#   Valid options are nfs, fc, iscsi, and posixfs.
#
# [*organization*]
#   This setting can be used to override the default ovirt PKI organization of
#   localdomain.
#
# [*nfs_config_enabled*]
#   This setting can be used to override the default ovirt nfs configuration of
#   true.  Valid options are true and false.
#
# [*iso_domain_name*]
#   This setting can be used to override the default ISO Domain Name of
#   ISO_DOMAIN.
#
# [*iso_domain_mount_point*]
#   This setting can be used to override the default ISO Domain Mount Point
#   of /var/lib/exports/iso.
#
# [*admin_password*]
#   This setting can be used to override the default ovirt admin password of
#   admin.
#
# [*db_user*]
#   This setting can be used to override the default database user of engine.
#
# [*db_password*]
#   This setting can be used to override the default database password of
#   dbpassword.
#
# [*db_host*]
#   This setting can be used to override the default database host of localhost.
#
# [*db_port*]
#   This setting can be used to override the default database port of 5432.
#
# [*firewall_manager*]
#   This setting can be used to override the default firewall manager.  The
#   module uses iptables for RHEL and CentOS and firewalld for Fedora by
#   default.  Valid options are iptables and firewalld.
#
# === Examples
#
#  class { ovirt::selfhosted:
#    application_mode => 'ovirt',
#    storage_type    => 'fc',
#    organization    => 'example.com',
#  }
#
# === Authors
#
# Jason Cannon <jason@thisidig.com>
#
class ovirt::selfhosted(
  $application_mode         = 'both', # both, virt, gluster
  $storage_type             = 'nfs', # nfs, fc, iscsi, posixfs
  $organization             = 'localdomain',
  $nfs_config_enabled       = true, # true, false
  $iso_domain_name          = 'ISO_DOMAIN',
  $iso_domain_mount_point   = '/var/lib/exports/iso',
  $admin_password           = 'admin',
  $db_user                  = 'engine',
  $db_password              = 'dbpassword',
  $db_host                  = 'localhost',
  $db_port                  = '5432',
  $firewall_manager = $::operatingsystem ? {
    /(?i-mx:centos|redhat)/ => 'iptables',
    /(?i-mx:fedora)/        => 'firewalld',
  }
) inherits ovirt {

  package { 'ovirt-hosted-engine-setup':
    ensure  => installed,
    require => Package[$ovirt::ovirt_release],
    notify  => Exec[hosted-engine],
  }

  $answers_file='/var/lib/ovirt-hosted-engine-ha/setup/answers/answers-from-puppet'

  file { $answers_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[ovirt-hosted-engine-setup],
    content => template('ovirt/answers.erb'),
  }

  service { 'ovirt-hosted-engine-setup':
    ensure  => 'running',
    enable  => true,
    require => Package[ovirt-hosted-engine-setup],
  }

  exec { 'hosted-engine':
    require     => [
      Package[ovirt-hosted-engine-setup],
      File[$answers_file],
    ],
    refreshonly => true,
    path        => '/usr/bin/:/bin/:/sbin:/usr/sbin',
    command     => "yes 'Yes' | hosted-engine --deploy --config-append=${answers_file}",
    notify      => Service[ovirt-hosted-engine-setup],
  }
}

