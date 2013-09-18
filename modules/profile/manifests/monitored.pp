#
class profile::monitored inherits profile::base {
  include nrpe
  include wr::mcollective
  include nagios::target

  $is_virtual_bool = any2bool($::is_virtual)
  if $::is_virtual_bool == false and $::manufacturer =~ /Dell/ {
    include profile::bare_metal
  }

  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['wr::mcollective']
  Class['wr::common::repos'] -> Class['nagios::target']
}
