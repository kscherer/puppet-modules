#
class profile::monitored inherits profile::base {

  include wr::mcollective
  Class['wr::common::repos'] -> Class['wr::mcollective']

  $is_virtual_bool = any2bool($::is_virtual)
  if $is_virtual_bool == false and $::manufacturer =~ /Dell/ and $::productname !~ /(OptiPlex|Precision)/ {
    include profile::bare_metal
  }

  include nrpe
  include nagios::target
  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['nagios::target']
}
