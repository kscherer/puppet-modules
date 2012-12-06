# Class: collectd
#
# This class installs and configures collectd
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class collectd(
  $plugins = hiera_array('collectd::plugins',['collectd::plugin::base'])
  ) {

  package { 'collectd':
    ensure => present,
  }

  case $::operatingsystem {
    RedHat,CentOS: { Yumrepo['collectd'] -> Package['collectd'] }
    default: {}
  }

  service { 'collectd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['collectd'];
  }

  #each plugin will put its configuration into this directory
  file {
    '/etc/collectd.d':
      ensure  => directory,
      recurse => true,
      purge   => true,
      notify  => Service['collectd'];
  }

  #of course debian and redhat have the conf file in different places
  case $::osfamily {
    RedHat:  { $collectd_conf_path = '/etc/collectd.conf' }
    default: {  $collectd_conf_path = '/etc/collectd/collectd.conf' }
  }

  #Setup basic configuration, all plugins are enabled and configured in /etc/collectd.d
  file {
    'collectd_conf':
      ensure  => present,
      path    => $collectd_conf_path,
      content => template('collectd/collectd-client.conf.erb'),
      notify  => Service['collectd'],
      require => [ Package['collectd'], File['/etc/collectd.d']];
  }

  include $plugins
}
