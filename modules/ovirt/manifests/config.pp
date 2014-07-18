# Class: ovirt::config
#
# This module contain the configuration for sSMTP
#
# Parameters:   This module has no parameters
#
# Actions:      This module has no actions
#
# Requires:     This module has no requirements
#
# Sample Usage: include ovirt::config
#
class ovirt::config {
  # oVirt configuration
  if $ovirt::type == 'engine' {
    file {
      $ovirt::params::configOvirtDirectory:
        ensure  => directory,
        mode    => '0755',
        owner   => root,
        group   => root;

      $ovirt::params::configOvirtIsoDirectory:
        ensure  => directory,
        mode    => '0755',
        owner   => root,
        group   => root;
    }

    file {
      $ovirt::params::configOvirtAnswer:
        ensure  => present,
        mode    => '0644',
        owner   => root,
        group   => root,
        path    => $ovirt::params::configOvirtAnswer,
        content => template($ovirt::params::configOvirtAnswerTemplate);
    }

    exec { 'engine-setup':
      require     => [
        Package[$ovirt::params::packageEngine],
        File[$ovirt::params::configOvirtAnswer],
      ],
      refreshonly => true,
      path        => '/usr/bin/:/bin/:/sbin:/usr/sbin',
      command     => "yes 'Yes' | engine-setup --config-append=${ovirt::params::configOvirtAnswer}",
      notify      => Service[$ovirt::params::serviceEngine],
    }
  }
}
