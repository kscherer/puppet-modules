# Class: ovirt::params
#
# This module contain the parameters for oVirt
#
# Parameters:   This module has no parameters
#
# Actions:      This module has no actions
#
# Requires:     This module has no requirements
#
# Sample Usage: include ovirt::params
#
class ovirt::params {

  # Operating system specific definitions
  case $::osfamily {
    'RedHat' : {
      $linux = true

      # Package definition
      $packageEngine              = 'ovirt-engine'
      $packageNode                = 'vdsm'
      $packageRepoFile            = '/etc/yum.repos.d/ovirt.repo'
      $packageRepoFileTemplate    = 'ovirt/etc/yum.repos.d/ovirt.repo.erb'

      # Config definition
      $configOvirtDirectory       = '/srv/ovirt'
      $configOvirtIsoDirectory    = '/srv/ovirt/iso'
      $configOvirtAnswer          = '/srv/ovirt/answer-file'
      $configOvirtAnswerTemplate  = 'ovirt/srv/ovirt.conf.erb'

      # Service definition
      $serviceEngine              = 'ovirt-engine'
      $serviceNode                = 'vdsmd'
    }
    default  : {
      $linux = false
    }
  }

  # oVirt default definitions
  $adminPassword   = 'S3cr3t!'
  $storage         = 'nfs'
  $organization    = 'default-company'
  $applicationMode = 'both'
  $firewallManager = 'iptables'
  $dbUser          = 'ovirt'
  $dbPassword      = 'ovirt'
}
