#
class profile::monitored inherits profile::base {

  include wr::mcollective
  Class['wr::common::repos'] -> Class['wr::mcollective']

  $is_virtual_bool = any2bool($::is_virtual)
  if $is_virtual_bool == false and $::manufacturer =~ /Dell/ and $::productname !~ /(OptiPlex|Precision)/ {
    include profile::bare_metal
  }

  if ($::osfamily == 'RedHat' and $::lsbmajdistrelease == '7') {
    $nagios_plugins_available=false
  } else {
    $nagios_plugins_available=true
  }

  if $nagios_plugins_available {
    include nrpe
    include nagios::target
    Class['wr::common::repos'] -> Class['nrpe']
    Class['wr::common::repos'] -> Class['nagios::target']
  }
}
