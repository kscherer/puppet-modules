# Class: collectd
#
# This class installs and configures collectd
#
# Parameters:
#
# Actions:
#
# Requires:
#   - The collectd::params class
#
# Sample Usage:
#
class collectd {
  package { 'collectd':
    ensure => present,
  }

  service { 'collectd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['collectd'];
  }
}
