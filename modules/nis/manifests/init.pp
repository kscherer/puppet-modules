# Setup up NIS and autofs
class nis {

  package {
    ['ypbind','autofs']:
      ensure => installed;
  }

  #needed so that network service can be restarted
  include network

  #Note this is for redhat machines only
  file_line {
    'nisdomain':
      ensure => present,
      path   => '/etc/sysconfig/network',
      line   => 'NISDOMAIN=swamp',
      notify => Service['network'];
  }

  file {
    '/etc/yp.conf':
      content => 'domain swamp server 128.224.144.20',
      owner   => root, group => root, mode => '0644',
      require => Package['ypbind'];
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/nis/nsswitch.conf',
      owner   => root, group => root, mode => '0644',
      require => Package['ypbind'];
    '/etc/auto.master':
      source  => 'puppet:///modules/nis/auto.master',
      owner   => root, group => root, mode => '0644',
      require => Package['autofs'];
    ['/net','/folk']:
      ensure  => directory,
      notify  => Service['autofs'];
  }

  service {
    'ypbind':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => [ File['/etc/yp.conf'], File['/etc/nsswitch.conf'],
                      Line['nisdomain'], Package['ypbind']];
  }

  service {
    'autofs':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => [ File['/etc/auto.master'], Package['autofs'],
                      File['/folk']];
  }
}
