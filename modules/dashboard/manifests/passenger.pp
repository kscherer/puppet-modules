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
  $dashboard_site    = $dashboard::params::dashboard_site,
  $dashboard_port    = $dashboard::params::dashboard_port,
  $passenger_ensure  = undef,
  $passenger_package = undef,
) inherits dashboard {

  Package[$passenger_package]
  -> Apache::Vhost["dashboard-${dashboard_site}"]

  file { '/etc/init.d/puppet-dashboard':
    ensure => absent,
  }

  apache::vhost { "dashboard-${dashboard_site}":
    port        => $dashboard_port,
    priority    => '50',
    docroot     => '/usr/share/puppet-dashboard/public',
    template    => 'dashboard/puppet-dashboard-passenger-vhost.erb',
    serveradmin => 'Konrad.Scherer@windriver.com',
  }

}
