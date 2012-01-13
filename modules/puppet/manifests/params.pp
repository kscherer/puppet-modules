# Class: puppet::params
#
# This class installs and configures parameters for Puppet
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::params {

  $puppet_server                    = 'aserver.puppetlabs.lan'
  $puppet_storeconfigs_password     = 'password'
  $modulepath                       = "/etc/puppet/modules"
  $storeconfigs_dbadapter           = 'mysql'
  $storeconfigs_dbuser              = 'puppet'
  $storeconfigs_dbpassword          = 'password'
  $storeconfigs_dbserver            = 'localhost'
  $storeconfigs_dbsocket            = '/var/run/mysqld/mysqld.sock'
  $certname                         = $fqdn
  $confdir                          = '/etc/puppet/puppet.conf'
  $manifest                         = '/etc/puppet/manifests/site.pp'
  $puppet_site                      = $fqdn
  $puppet_docroot                   = '/etc/puppet/rack/public/'
  $puppet_passenger_port            = '8140'
  $mysql_root_pw                    = 'changemetoo'
  $activerecord_provider            = 'gem'
  $activerecord_package             = 'activerecord'
  $activerecord_ensure              = 'installed'

  case $operatingsystem {
    'centos', 'redhat', 'fedora': {
      $puppet_master_package        = 'puppet-server'
      $puppet_master_service        = 'puppetmaster'
      $puppet_agent_service         = 'puppet'
      $puppet_agent_name            = 'puppet'
      $puppet_defaults              = '/etc/sysconfig/puppet'
      $puppet_dashboard_report      = ''
      $puppet_storeconfigs_packages = 'mysql-devel'
      $puppet_conf                  = '/etc/puppet/puppet.conf'
      $puppet_logdir                = '/var/log/puppet'
      $puppet_vardir                = '/var/lib/puppet'
      $puppet_ssldir                = '/var/lib/puppet/ssl'
      $package_provider             = 'yum'
      $mysql_package_provider       = 'yum'
      $ruby_mysql_package           = 'ruby-mysql'
   }
    'ubuntu', 'debian': {
      $puppet_master_package        = 'puppetmaster'
      $puppet_master_service        = 'puppetmaster'
      $puppet_agent_service         = 'puppet'
      $puppet_agent_name            = 'puppet'
      $puppet_defaults              = '/etc/default/puppet'
      $puppet_dashboard_report      = '/usr/lib/ruby/1.8/puppet/reports/puppet_dashboard.rb'
      $puppet_storeconfigs_packages = 'libmysql-ruby'
      $puppet_conf                  = '/etc/puppet/puppet.conf'
      $puppet_logdir                = '/var/log/puppet'
      $puppet_vardir                = '/var/lib/puppet'
      $puppet_ssldir                = '/var/lib/puppet/ssl'
      $package_provider             = 'aptitude'
      $mysql_package_provider       = 'aptitude'
      $ruby_mysql_package           = 'libmysql-ruby1.8'
    }
    'freebsd': {
      $puppet_agent_service         = 'puppet'
      $puppet_agent_name            = 'puppet'
      $puppet_conf                  = '/usr/local/etc/puppet/puppet.conf'
      $puppet_logdir                = '/var/log/puppet'
      $puppet_vardir                = '/var/puppet'
      $puppet_ssldir                = '/var/puppet/ssl'
      $package_provider             = 'ports'
      $mysql_package_provider       = 'gem'
      $ruby_mysql_package           = 'mysql'
    }
    'darwin': {
      $puppet_agent_service         = 'com.puppetlabs.puppet'
      $puppet_agent_name            = 'puppet'
      $puppet_conf                  = '/etc/puppet/puppet.conf'
      $puppet_logdir                = '/var/log/puppet'
      $puppet_vardir                = '/var/lib/puppet'
      $puppet_ssldir                = '/etc/puppet/ssl'
      $package_provider             = 'apple'
      $mysql_package_provider       = 'gem'
      $ruby_mysql_package           = 'mysql'
    }
    default: {
      warning("Operating system $operatingsystem not supported.")
    }
  }
}
