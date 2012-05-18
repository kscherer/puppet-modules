#
class nx::yow-blades {

  file {
    '/mnt/yow-blades':
      ensure => directory,
      owner  => root,
      group  => root;
    '/mnt/rpm_cache':
      ensure => directory,
      owner  => '8023',
      group  => '100';
  }

  mount {
    '/mnt/yow-blades':
      ensure   => mounted,
      atboot   => true,
      device   => 'yow-lpgnas2:/vol/vol1',
      fstype   => nfs,
      options  => 'rw,_netdev',
      require  => File['/mnt/yow-blades'],
      remounts => true;
    'rpm_cache':
      ensure   => mounted,
      atboot   => true,
      device   => 'yow-lpggp1:/yow-lpggp15/prebuilt_cache/',
      name     => '/mnt/rpm_cache',
      fstype   => 'nfs',
      options  => 'ro,soft,auto,nolock,_netdev',
      require  => File['/mnt/rpm_cache'],
      remounts => false;
  }

  #create four nx instances
  nx::setup {
    [ '1', '2' ]:
  }

  case $::hostname {
    /^yow-blade[1-8]$/: { include nx::netapp_iscsi_setup }
    yow-blade9: { include nx::md3000_iscsi_setup }
    /^yow-blade1[0-6]$/: { include nx::md3000_iscsi_setup }
    default: { fail("Do not know how to configure nx for $::hostname")}
  }
}

class nx::md3000_iscsi_setup {

  #retrieve the uuid of the multipath disks
  $wwid_disk1 = extlookup('wwid_disk1')
  $wwid_disk2 = extlookup('wwid_disk2')

  class{ 'iscsi::md3000': }
  -> class{ 'multipath':
    wwid_disk1 => $wwid_disk1,
    wwid_disk2 => $wwid_disk2,
  }
  -> Anchor['nx::begin']
  -> Class['nx::md3000_iscsi_setup']
  -> Class['nx::yow-blades']
  -> Anchor['nx::end']

  file {
    [ "/ba1/${::hostname}.1","/ba1/${::hostname}.3",
      "/ba2/${::hostname}.2","/ba2/${::hostname}.4" ]:
        ensure  => directory,
        owner   => nxadm,
        group   => nxadm,
        mode    => '0755',
        require => [ Mount['/ba1'], Mount['/ba2']];
      '/home/nxadm/nx':
        ensure  => directory,
        mode    => '0755',
        require => File['/home/nxadm'];
      "/home/nxadm/nx/${::hostname}.1":
        ensure => link,
        target => "/ba1/${::hostname}.1";
      "/home/nxadm/nx/${::hostname}.2":
        ensure => link,
        target => "/ba2/${::hostname}.2";
      "/home/nxadm/nx/${::hostname}.3":
        ensure => link,
        target => "/ba1/${::hostname}.3";
      "/home/nxadm/nx/${::hostname}.4":
        ensure => link,
        target => "/ba2/${::hostname}.4";
  }
}

class nx::netapp_iscsi_setup {

  class{ 'iscsi::netapp': }
  -> Anchor['nx::begin']
  -> Class['nx::netapp_iscsi_setup']
  -> Class['nx::yow-blades']
  -> Anchor['nx::end']

  file {
    '/buildarea':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    '/buildarea/nxadm':
      ensure  => directory,
      require => Mount['/buildarea'],
      mode    => '0755';
    '/buildarea/nxadm/nx':
      ensure  => directory,
      require => File['/buildarea/nxadm'],
      mode    => '0755';
    '/home/nxadm/nx':
      ensure  => link,
      target  => '/buildarea/nxadm/nx',
      replace => false;
    [ "/buildarea/nxadm/nx/${::hostname}.1",
      "/buildarea/nxadm/nx/${::hostname}.2",
      "/buildarea/nxadm/nx/${::hostname}.3",
      "/buildarea/nxadm/nx/${::hostname}.4"]:
        ensure  => directory,
        mode    => '0755',
        replace => false;
    }

    $iscsi_uuid = extlookup('iscsi_uuid')

    case $::hostname  {
      yow-blade7: {
        $fstype = 'ext4'
        $options = 'noatime,nodiratime,_netdev'
      }
      default: {
        $fstype = 'ext3'
        $options = 'noatime,nodiratime,data=writeback,_netdev,reservation,commit=100'
      }
    }

    mount {
    '/buildarea':
      ensure   => mounted,
      atboot   => true,
      device   => "UUID=$iscsi_uuid",
      fstype   => $fstype,
      options  => $options,
      require  => [ File['/buildarea'], Iscsi::Connection['iface0']],
      remounts => true;
  }
}
