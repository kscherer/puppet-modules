#
class profile::monitored inherits profile::base {
  include nrpe
  include wr::mcollective
  include nagios::target

  if $::isvirtual == false and $::manufacturer == 'Dell Inc.' {
    include profile::bare_metal
  }

  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['wr::mcollective']
  Class['wr::common::repos'] -> Class['nagios::target']
}
