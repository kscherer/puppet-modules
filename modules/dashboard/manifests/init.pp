# Class: puppet::dashboard
#
# This class installs and configures parameters for Puppet Dashboard
#
# Parameters:
#   [*dashboard_ensure*]      - The value of the ensure parameter for the
#                               puppet-dashboard package
#   [*dashboard_user*]        - Name of the puppet-dashboard database and
#                               system user
#   [*dashboard_group*]       - Name of the puppet-dashboard group
#   [*dashbaord_password*]    - Password for the puppet-dashboard database use
#   [*dashboard_db*]          - The puppet-dashboard database name
#   [*dashboard_charset*]     - Character set for the puppet-dashboard database
#   [*dashboard_site*]        - The ServerName setting for Apache
#   [*dashboard_port*]        - The port on which puppet-dashboard should run
#   [*mysql_root_pw*]         - Password for root on MySQL
#   [*passenger*]             - Boolean to determine whether Dashboard is to be
#                               used with Passenger
#   [*mysql_package_provider*] - The package provider to use when installing
#                               the ruby-mysql package
#   [*ruby_mysql_package*]     - The package name for the ruby-mysql package
#
# Actions:
#
# Requires:
# Class['mysql']
# Class['mysql::ruby']
# Class['mysql::server']
# Apache::Vhost[$dashboard_site]
#
# Sample Usage:
#   class {'dashboard':
#     dashboard_ensure          => 'present',
#     dashboard_user            => 'puppet-dbuser',
#     dashboard_group           => 'puppet-dbgroup',
#     dashboard_password        => 'changemme',
#     dashboard_db              => 'dashboard_prod',
#     dashboard_charset         => 'utf8',
#     dashboard_site            => $fqdn,
#     dashboard_port            => '8080',
#     mysql_root_pw             => 'REALLY_change_me',
#     passenger                 => true,
#     mysql_package_provider    => 'yum',
#     ruby_mysql_package        => 'ruby-mysql',
#   }
#
#  Note: SELinux on Redhat needs to be set separately to allow access to the
#   puppet-dashboard.
#
class dashboard (
  $dashboard_ensure         = $dashboard::params::dashboard_ensure,
  $dashboard_user           = $dashboard::params::dashboard_user,
  $dashboard_group          = $dashboard::params::dashboard_group,
  $dashboard_password       = $dashboard::params::dashboard_password,
  $dashboard_db             = $dashboard::params::dashboard_db,
  $dashboard_charset        = $dashboard::params::dashboard_charset,
  $dashboard_site           = $dashboard::params::dashboard_site,
  $dashboard_port           = $dashboard::params::dashboard_port,
  $dashboard_service        = $dashboard::params::dashboard_service,
  $mysql_root_pw            = $dashboard::params::mysql_root_pw,
  $passenger                = $dashboard::params::passenger,
  $passenger_ensure         = undef,
  $passenger_package        = undef,
  $passenger_provider       = 'gem',
  $mysql_package_provider   = $dashboard::params::mysql_package_provider,
  $ruby_mysql_package       = $dashboard::params::ruby_mysql_package
) inherits dashboard::params {

  if ! defined(Class['mysql']) {
    class { 'mysql': }
    class { 'mysql::server': config_hash => { root_password => $mysql_root_pw } }
    class { 'mysql::ruby':
      package_provider => $dashboard::params::mysql_package_provider,
      package_name     => $dashboard::params::ruby_mysql_package,
    }
  }

  if $passenger {
    Class['mysql']
    -> Class['mysql::ruby']
    -> Class['mysql::server']
    -> Package[$dashboard::params::dashboard_package]
    -> Mysql::DB[$dashboard_db]
    -> File["${dashboard::params::dashboard_root}/config/database.yml"]
    -> Exec['db-migrate']
    -> Class['dashboard::passenger']
    -> Service[$dashboard::params::dashboard_workers]

    class { 'dashboard::passenger':
      dashboard_site     => $dashboard_site,
      dashboard_port     => $dashboard_port,
      passenger_ensure   => $passenger_ensure,
      passenger_package  => $passenger_package,
      passenger_provider => $passenger_provider,
    }

  } else {
    Class['mysql']
    -> Class['mysql::ruby']
    -> Class['mysql::server']
    -> Package[$dashboard::params::dashboard_package]
    -> Mysql::DB[$dashboard_db]
    -> File["${dashboard::params::dashboard_root}/config/database.yml"]
    -> Exec['db-migrate']
    -> Service[$dashboard::params::dashboard_service]
    -> Service[$dashboard::params::dashboard_workers]

    service { $dashboard::params::dashboard_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      subscribe  => File['/etc/puppet-dashboard/database.yml'],
      require    => Exec['db-migrate']
    }
  }

  package { $dashboard::params::dashboard_package:
    ensure => $dashboard_ensure,
  }

  case $::operatingsystem {
    'centos','redhat','oel': {
      $dashboard_defaults_name = '/etc/sysconfig/puppet-dashboard'
      $dashboard_defaults_content = 'dashboard/puppet-dashboard-sysconfig'
    }
    'debian','ubuntu': {
      $dashboard_defaults_name = '/etc/default/puppet-dashboard'
      $dashboard_defaults_content = 'dashboard/puppet-dashboard-default.erb'
    }
    default: { }
  }

  file { 'dashboard-defaults' :
    ensure    => present,
    path      => $dashboard_defaults_name,
    content   => template($dashboard_defaults_content),
    owner     => '0',
    group     => '0',
    mode      => '0644',
    require   => [Package[$dashboard::params::dashboard_package],
                User[$dashboard_user] ],
    before    => $passenger ? {
      false   => Service[$dashboard_service],
      default => undef,
    }
  }

  service { $dashboard::params::dashboard_workers:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    subscribe  => File['dashboard-defaults'],
  }

  File {
    require => Package[$dashboard::params::dashboard_package],
    mode    => '0755',
    owner   => $dashboard_user,
    group   => $dashboard_group,
  }

  file { [ "${dashboard::params::dashboard_root}/public", "${dashboard::params::dashboard_root}/tmp", "${dashboard::params::dashboard_root}/log", '/etc/puppet-dashboard' ]:
    ensure       => directory,
    recurse      => true,
    recurselimit => '1',
  }

  file {'/etc/puppet-dashboard/database.yml':
    ensure  => present,
    content => template('dashboard/database.yml.erb'),
  }

  file { "${dashboard::params::dashboard_root}/config/database.yml":
    ensure => 'symlink',
    target => '/etc/puppet-dashboard/database.yml',
  }

  file { [ "${dashboard::params::dashboard_root}/log/production.log", "${dashboard::params::dashboard_root}/config/environment.rb" ]:
    ensure => file,
    mode   => '0644',
  }

  file { '/etc/logrotate.d/puppet-dashboard':
    ensure  => present,
    content => template('dashboard/puppet-dashboard.logrotate.erb'),
    owner   => '0',
    group   => '0',
    mode    => '0644',
  }

  exec { 'db-migrate':
    command   => 'rake RAILS_ENV=production db:migrate',
    cwd       => $dashboard::params::dashboard_root,
    path      => '/usr/bin/:/usr/local/bin/',
    creates   => "/var/lib/mysql/${dashboard_db}/nodes.frm",
  }

  mysql::db {
    $dashboard_db:
      user     => $dashboard_user,
      password => $dashboard_password,
      charset  => $dashboard_charset,
  }

  user {
    $dashboard_user:
      ensure     => 'present',
      comment    => 'Puppet Dashboard',
      gid        => $dashboard_group,
      shell      => '/sbin/nologin',
      managehome => true,
      home       => "/home/${dashboard_user}",
  }

  group {
    $dashboard_group:
      ensure => 'present',
  }

}

