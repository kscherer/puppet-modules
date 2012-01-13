# Class: dashboard::passenger
#
# This class configures parameters for the puppet-dashboard module.
#
# Parameters:
#   [*dashboard_site*]  - The ServerName setting for Apache
#   [*dashboard_port*]  - The port on which puppet-dashboard should run
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class dashboard::passenger (
  $dashboard_site,
  $dashboard_port,
  $passenger_ensure = undef,
  $passenger_package = undef,
  $passenger_provider = 'gem'
) inherits dashboard {

  Class ['::passenger']
  -> Apache::Vhost["dashboard-$dashboard_site"]

  if ! defined(Class['::passenger']) {
    class { '::passenger':
      passenger_ensure   => $passenger_ensure,
      passenger_package  => $passenger_package,
      passenger_provider => $passenger_provider,
    }
  }

  file { '/etc/init.d/puppet-dashboard':
    ensure => absent,
  }

  apache::vhost { "dashboard-$dashboard_site":
    port     => $dashboard_port,
    priority => '50',
    docroot  => '/usr/share/puppet-dashboard/public',
    template => 'dashboard/puppet-dashboard-passenger-vhost.erb',
  }

}
