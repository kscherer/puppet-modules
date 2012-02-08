# Class: apache
#
# This class installs Apache
#
# Parameters:
#
# Actions:
#   - Install Apache
#   - Manage Apache service
#
# Requires:
#
# Sample Usage:
#
class apache {
  include apache::params
  package {
    'httpd':
      ensure => installed,
      name   => $apache::params::apache_name,
  }
  service {
    'httpd':
      ensure    => running,
      name      => $apache::params::apache_name,
      enable    => true,
      subscribe => Package['httpd'],
  }

  # May want to purge all none realize modules using the resources resource type.
  #
  A2mod { require => Package['httpd'], notify => Service['httpd']}
  case $::operatingsystem {
    'debian','ubuntu': {
      @a2mod {
        'rewrite' : ensure => present;
        'headers' : ensure => present;
        'expires' : ensure => present;
      }
    }
    default: { }
  }
}
