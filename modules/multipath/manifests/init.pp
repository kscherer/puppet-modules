#how the mount is defined
define multipath::mount($device) {
  mount {
    $name:
      ensure   => mounted,
      atboot   => true,
      device   => $device,
      fstype   => ext3,
      options  => 'noatime,nodiratime,data=writeback,_netdev,reservation,commit=100',
      require  => [ File[$name], Service['multipathd'] ],
      remounts => true;
  }
}

#This class currently assumes 2 multipath disks
class multipath(
  $wwid_disk1,
  $wwid_disk2 = 'UNSET'
  ) {

  package {
    'device-mapper-multipath':
      ensure => installed;
  }

  service {
    'multipathd':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [ Package['device-mapper-multipath']];
  }

  file {
    '/etc/multipath.conf':
      content => template('multipath/multipath.conf.erb'),
      require => Package['device-mapper-multipath'],
      notify  => [ Service[ 'multipathd' ], Exec['create_multipath'] ],
      owner   => root, group => root, mode => '0644';
  }

  # setup the multipath configuration. To be safe, first clear all
  # previous config. Only do the command if there are valid iscsi sessions
  exec {
    'create_multipath':
      command     => 'multipath -F; multipath',
      path        => '/usr/bin/:/sbin/:/bin',
      onlyif      => 'iscsiadm -m session',
      refreshonly => true,
      require     => File['/etc/multipath.conf'],
      notify      => Service['multipathd'];
  }

  #base directories to hold build areas
  file {
    ['/ba1','/ba2']:
      ensure => directory,
      owner  => root, group => root;
  }

  mpath_mount {
    '/ba1':
      device => '/dev/mapper/ba1p1';
    '/ba2':
      device => '/dev/mapper/ba2p1';
  }
}
