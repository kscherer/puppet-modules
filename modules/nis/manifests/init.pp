# Setup up NIS and autofs
class nis {

  package {
    ['ypbind','autofs']:
      ensure => installed;
  }

  #needed so that network service can be restarted
  include network

  #Note this is for redhat machines only
  line {
    'nisdomain':
      file   => '/etc/sysconfig/network',
      line   => 'NISDOMAIN=swamp',
      ensure => present,
      notify => Service['network'];
  }

  file {
    '/etc/yp.conf':
      content => 'domain swamp server 128.224.144.20',
      owner   => root, group => root, mode => 644,
      require => Package['ypbind'];
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/nis/nsswitch.conf',
      owner   => root, group => root, mode => 644,
      require => Package['ypbind'];
    '/etc/auto.master':
      source  => 'puppet:///modules/nis/auto.master',
      owner   => root, group => root, mode => 644,
      require => Package['autofs'];
    ['/net','/folk']:
      notify  => Service['autofs'],
      ensure  => directory;
  }

  service {
    'ypbind':
      enable     => true,
      ensure     => running,
      hasrestart => true,
      hasstatus  => true,
      require    => [ File['/etc/yp.conf'], File['/etc/nsswitch.conf'],
                      Line['nisdomain'], Package['ypbind']];
  }

  service {
    'autofs':
      enable     => true,
      ensure     => running,
      hasrestart => true,
      hasstatus  => true,
      require    => [ File['/etc/auto.master'], Package['autofs'],
                      File['/folk']];
  }

}
