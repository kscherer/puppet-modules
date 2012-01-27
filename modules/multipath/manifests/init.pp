#This class currently assumes 2 multipath disks
class multipath {
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

  $wwid_disk1 = extlookup('wwid_disk1')
  $wwid_disk2 = extlookup('wwid_disk2')

  file {
    "/etc/multipath.conf":
      content  => template('iscsi/multipath.conf.erb'),
      require => Package['device-mapper-multipath'],
      notify  => [ Service[ 'multipathd' ], Exec['create_multipath'] ],
      owner   => root, group => root, mode => 0644;
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
      owner => root, group => root,
      ensure => directory;
  }

  #how the mount is defined
  define mpath_mount($device) {
    mount {
      "$name":
        atboot => true,
        device => "$device",
        ensure => mounted,
        fstype => ext3,
        options => 'noatime,nodiratime,data=writeback,_netdev,reservation,commit=100',
        require => [ File["$name"], Service['multipathd'] ],
        remounts => true;
      }
  }

  mpath_mount {
    '/ba1':
      device => '/dev/mapper/ba1p1';
    '/ba2':
      device => '/dev/mapper/ba2p1';
  }
}

