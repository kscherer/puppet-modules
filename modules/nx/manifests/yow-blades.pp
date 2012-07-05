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

  #create nx instances
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
