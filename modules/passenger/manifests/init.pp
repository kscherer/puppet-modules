# Class: passenger
#
# This class installs Passenger (mod_rails) on your system.
# http://www.modrails.com
#
# Parameters:
#   [*passenger_ensure*]        - The version of Passenger to be installed
#   [*gem_path*]                - Rubygems path on your system
#   [*gem_binary_path*]         - Path to Rubygems binaries on your system
#   [*mod_passenger_location*]  - Path to Passenger's mod_passenger.so file
#   [*passenger_provider*]      - The package provider to install Passenger
#   [*passenger_package*]       - The name of the Passenger package
#
# Actions:
#   - Install passenger gem
#   - Compile passenger module
#
# Requires:
#   - gcc
#   - apache::dev
#
# Sample Usage:
#
class passenger (
  $passenger_ensure       = $passenger::params::passenger_ensure,
  $gem_path               = $passenger::params::gem_path,
  $gem_binary_path        = $passenger::params::gem_binary_path,
  $mod_passenger_location = $passenger::params::mod_passenger_location,
  $passenger_provider     = $passenger::params::passenger_provider,
  $passenger_package      = $passenger::params::passenger_package
) inherits passenger::params
{
  $v_alphanum = '^[._0-9a-zA-Z:-]+$'
  validate_re($passenger_ensure, $v_alphanum)

  class { 'apache': }

  if $passenger_provider == 'gem' {

    case $operatingsystem {
      'ubuntu', 'debian': {
        file { '/etc/apache2/mods-available/passenger.load':
          ensure  => present,
          content => template('passenger/passenger-load.erb'),
          owner   => '0',
          group   => '0',
          mode    => '0644',
        }

        file { '/etc/apache2/mods-available/passenger.conf':
          ensure  => present,
          content => template('passenger/passenger-enabled.erb'),
          owner   => '0',
          group   => '0',
          mode    => '0644',
        }

        file { '/etc/apache2/mods-enabled/passenger.load':
          ensure  => 'link',
          owner   => '0',
          group   => '0',
          mode    => '0777',
          require => File['/etc/apache2/mods-available/passenger.load'],
        }

        file { '/etc/apache2/mods-enabled/passenger.conf':
          ensure  => 'link',
          owner   => '0',
          group   => '0',
          mode    => '0777',
          require => File['/etc/apache2/mods-available/passenger.conf'],
        }
      }
      'centos', 'fedora', 'redhat': {
        file { '/etc/httpd/conf.d/passenger.conf':
          ensure  => present,
          content => template('passenger/passenger-conf.erb'),
          owner   => '0',
          group   => '0',
          mode    => '0644',
        }
      }
      'darwin':{}
    }

    package {'passenger':
      name     => $passenger_package,
      ensure   => $passenger_ensure,
      provider => $passenger_provider,
    }

    #need the following to build passenger
    class { 'gcc': }
    class { 'apache::dev': }

    exec {'compile-passenger':
      path      => [ $gem_binary_path, '/usr/bin', '/bin'],
      command   => 'passenger-install-apache2-module -a',
      logoutput => on_failure,
      creates   => $mod_passenger_location,
      require   => Package['passenger'],
    }

    Class ['gcc']
    -> Class['apache::dev']
    -> Package <| title == 'rubygems' |>
    -> Package['passenger']
    -> Exec['compile-passenger']
  } else {
    package {
      'passenger':
        name => $passenger_package,
        ensure => $passenger_ensure,
        provider => $passenger_provider,
    }
  }

}
