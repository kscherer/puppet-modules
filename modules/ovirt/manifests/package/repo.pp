# Class: ovirt::package::repo
#
# This the main class for oVirt yum repository
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class ovirt::package::repo {
  file {
    $ovirt::params::packageRepoFile:
      ensure  => present,
      mode    => '0644',
      owner   => root,
      group   => root,
      path    => $ovirt::params::packageRepoFile,
      content => template($ovirt::params::packageRepoFileTemplate);
  }

  exec { 'yum_refresh':
    command     => '/usr/bin/yum clean all',
    refreshonly => true,
  }
  Exec['yum_refresh'] -> Package<||>
}
