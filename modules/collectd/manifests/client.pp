# Class: collectd::client
#
# This class configures the collectd client
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class collectd::client {
  include collectd::params
  include collectd

  file {
    '/etc/collectd.d':
      ensure  => directory;
    '/opt':
      ensure  => directory;
    '/opt/collectd-plugins':
      ensure  => directory,
      require => File['/opt'];
    '/opt/collectd-plugins/carbon_writer.py':
      ensure  => present,
      source  => 'puppet:///modules/collectd/carbon_writer.py',
      owner   => root, group => root, mode => '0644',
      notify  => Service['collectd'],
      require => [ File['/opt/collectd-plugins'], File['collectd-client']];
  }

  $collectd_server = $collectd::params::collectd_server
  $carbon_host = $collectd::params::carbon_host
  $carbon_line_receiver_port = $collectd::params::carbon_line_receiver_port

  #of course debian and redhat have the conf file in different places
  case $::operatingsystem {
    RedHat,Fedora,CentOS: { $collectd_conf_path = '/etc/collectd.conf' }
    default: {  $collectd_conf_path = '/etc/collectd/collectd.conf' }
  }

  file {
    'collectd-client':
      ensure  => present,
      path    => $collectd_conf_path,
      content => template('collectd/collectd-client.conf.erb'),
      notify  => Service['collectd'],
      require => [ Package['collectd'], File['/etc/collectd.d']];
  }

  if $::operatingsystem == 'Debian' {
    file {
      'collectd-libvirt':
        ensure  => present,
        path    => '/etc/collectd.d/libvirt.conf',
        source  => 'puppet:///modules/collectd/libvirt.conf',
        mode  => '0644',
        notify  => Service['collectd'],
        require => [ Package['collectd'], File['/etc/collectd.d']];
    }
  }

  case $::hostname {
    /^yow-blade.*$/ : {
      file {
        'collectd-blades':
          ensure  => present,
          path    => '/etc/collectd.d/blades.conf',
          source  => 'puppet:///modules/collectd/blades.conf',
          notify  => Service['collectd'],
          require => [ Package['collectd'], File['/etc/collectd.d']];
      }
      exec { 'update_collectd_initd' :
        command => "/bin/sed --in-place --expression 's#daemon /usr/sbin/collectd#LD_PRELOAD=/usr/lib64/libpython2.4.so daemon /usr/sbin/collectd#' /etc/init.d/collectd",
        unless => "/bin/grep -q 'LD_PRELOAD=/usr/lib64/libpython2.4.so' /etc/init.d/collectd",
        notify  => Service['collectd'],
        require => Package['collectd'];
      }
    }
    default: {}
  }
}
