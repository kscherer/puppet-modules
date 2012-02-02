# Class: puppet
#
# This class installs and configures Puppet Agent, Master, and Dashboard
#
# Parameters:
#
# Actions:
#
# Requires:
#
#  Class['dashboard']
#  Class['mysql'] <--Storeconfigs
#  Class['ruby']
#  Class['concat']
#  Class['stdlib']
#  Class['concat::setup']
#  Class['activerecord']
#
# Sample Usage:
#
class puppet (
  $puppet_master_ensure        = 'present',
  $master                      = false,
  $puppet_agent_ensure         = 'present',
  $agent                       = true,
  $puppet_agent_name           = $puppet::params::puppet_agent_name,
  $confdir                     = $puppet::params::confdir,
  $manifest                    = $puppet::params::manifest,
  $modulepath                  = $puppet::params::modulepath,
  $puppet_conf                 = $puppet::params::puppet_conf,
  $puppet_logdir               = $puppet::params::puppet_logdir,
  $puppet_vardir               = $puppet::params::puppet_vardir,
  $puppet_ssldir               = $puppet::params::puppet_ssldir,
  $puppet_defaults             = $puppet::params::puppet_defaults,
  $puppet_master_service       = $puppet::params::puppet_master_service,
  $puppet_agent_service        = $puppet::params::puppet_agent_service,
  $puppet_agent_service_enable = true,
  $puppet_server               = $puppet::params::puppet_server,
  $puppet_passenger            = false,
  $puppet_site                 = $puppet::params::puppet_site,
  $puppet_passenger_port       = $puppet::params::puppet_passenger_port,
  $passenger_ensure            = undef,
  $passenger_package           = undef,
  $passenger_provider          = 'gem',
  $puppet_docroot              = $puppet::params::puppet_docroot,
  $storeconfigs                = false,
  $thinstoreconfigs            = false,
  $storeconfigs_dbadapter      = $puppet::params::storeconfigs_dbadapter,
  $storeconfigs_dbuser         = $puppet::params::storeconfigs_dbuser,
  $storeconfigs_dbpassword     = $puppet::params::storeconfigs_dbpassword,
  $storeconfigs_dbserver       = $puppet::params::storeconfigs_dbserver,
  $storeconfigs_dbsocket       = $puppet::params::storeconfigs_dbsocket,
  $mysql_root_pw               = $puppet::params::mysql_root_pw,
  $certname                    = $puppet::params::certname,
  $autosign                    = false,
  $puppet_master_package       = $puppet::params::puppet_master_package,
  $package_provider            = $puppet::params::package_provider,
  $user_id                     = undef,
  $group_id                    = undef,
  $dashboard                   = false,
  $dashboard_ensure            = undef,
  $dashboard_user              = undef,
  $dashboard_group             = undef,
  $dashboard_password          = undef,
  $dashboard_db                = undef,
  $dashboard_charset           = undef,
  $dashboard_site              = undef,
  $dashboard_port              = undef,
  $dashboard_passenger         = undef,
  $mysql_package_provider      = $puppet::params::mysql_package_provider,
  $ruby_mysql_package          = $puppet::params::ruby_mysql_package,
  $activerecord_provider       = $puppet::params::activerecord_provider,
  $activerecord_package        = $puppet::params::activerecord_package,
  $activerecord_ensure         = $puppet::params::activerecord_ensure
) inherits puppet::params
{
  $v_alphanum = '^[._0-9a-zA-Z:-]+$'
  $v_path = '^[/$]'
  validate_re($puppet_master_ensure, $v_alphanum)
  validate_re($puppet_agent_ensure, $v_alphanum)
  $master_bool = any2bool($master)
  $agent_bool = any2bool($agent)
  $dashboard_bool = any2bool($dashboard)
  $storeconfigs_bool = any2bool($storeconfigs)
  $thinstoreconfigs_bool = any2bool($thinstoreconfigs)
  validate_re($puppet_conf, $v_path)
  validate_re($puppet_logdir, $v_path)
  validate_re($puppet_vardir, $v_path)
  validate_re($puppet_ssldir, $v_path)
  validate_re($puppet_defaults, $v_path)
  validate_re($puppet_master_service, $v_alphanum)
  validate_re($puppet_agent_service, $v_alphanum)
  validate_re($puppet_agent_name, $v_alphanum)
  validate_re($puppet_server, $v_alphanum)
  validate_re($storeconfigs_dbadapter,$v_alphanum)
  validate_re($storeconfigs_dbuser, $v_alphanum)
  validate_re($storeconfigs_dbpassword, $v_alphanum)
  validate_re($storeconfigs_dbsocket, $v_path)
  validate_re($storeconfigs_dbserver, $v_alphanum)
  validate_re($certname, $v_alphanum)
  validate_re($modulepath, $v_path)

  if $dashboard_bool {
    class {'dashboard':
      dashboard_ensure       => $dashboard_ensure,
      dashboard_group        => $dashboard_group,
      dashboard_db           => $dashboard_db,
      dashboard_charset      => $dashboard_charset,
      dashboard_site         => $dashboard_site,
      dashboard_port         => $dashboard_port,
      passenger              => $dashboard_passenger,
      passenger_ensure       => $passenger_ensure,
      passenger_package      => $passenger_package,
      passenger_provider     => $passenger_provider,
      mysql_package_provider => $mysql_package_provider,
      ruby_mysql_package     => $ruby_mysql_package,
      mysql_root_pw          => $mysql_root_pw,
      dashboard_user         => $dashboard_user,
      dashboard_password     => $dashboard_password,
    }
  }

  if $master_bool {
    class {'puppet::master':
      puppet_master_ensure      => $puppet_master_ensure,
      confdir                   => $confdir,
      puppet_server             => $puppet_server,
      puppet_passenger          => $puppet_passenger,
      passenger_ensure          => $passenger_ensure,
      passenger_package         => $passenger_package,
      passenger_provider        => $passenger_provider,
      puppet_site               => $puppet_site,
      puppet_passenger_port     => $puppet_passenger_port,
      puppet_docroot            => $puppet_docroot,
      puppet_vardir             => $puppet_vardir,
      modulepath                => $modulepath,
      storeconfigs              => $storeconfigs_bool,
      thinstoreconfigs          => $thinstoreconfigs_bool,
      storeconfigs_dbadapter    => $storeconfigs_dbadapter,
      storeconfigs_dbuser       => $storeconfigs_dbuser,
      storeconfigs_dbpassword   => $storeconfigs_dbpassword,
      storeconfigs_dbserver     => $storeconfigs_dbserver,
      storeconfigs_dbsocket     => $storeconfigs_dbsocket,
      mysql_root_pw             => $mysql_root_pw,
      certname                  => $certname,
      autosign                  => $autosign,
      manifest                  => $manifest,
      puppet_master_service     => $puppet_master_service,
      puppet_master_package     => $puppet_master_package,
      package_provider          => $package_provider,
      dashboard_port            => $dashboard_port, # needed for puppet.conf
      mysql_package_provider    => $mysql_package_provider,
      ruby_mysql_package        => $ruby_mysql_package,
      activerecord_provider     => $activerecord_provider,
      activerecord_package      => $activerecord_package,
      activerecord_ensure       => $activerecord_ensure,
    }
  }

  if $agent_bool {
    class {'puppet::agent':
      puppet_agent_ensure         => $puppet_agent_ensure,
      puppet_defaults             => $puppet_defaults,
      puppet_agent_service        => $puppet_agent_service,
      puppet_server               => $puppet_server,
      puppet_conf                 => $puppet_conf,
      puppet_agent_name           => $puppet_agent_name,
      package_provider            => $package_provider,
      puppet_agent_service_enable => $puppet_agent_service_enable,
    }
  }

  user { 'puppet':
    ensure => present,
    uid    => $user_id,
    gid    => 'puppet',
  }

  group { 'puppet':
    ensure => present,
    gid    => $group_id,
  }

  if ! defined(File['/etc/puppet']) {
    file { '/etc/puppet':
      ensure       => directory,
      group        => 'puppet',
      owner        => 'puppet',
      recurse      => true,
      recurselimit => '1',
    }
  }
}
