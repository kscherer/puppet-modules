#
class profile::monitored inherits profile::base {
  include nrpe
  include wr::mcollective
  include nagios::target

  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['wr::mcollective']
  Class['wr::common::repos'] -> Class['nagios::target']
}
