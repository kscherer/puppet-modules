#
class nx::yow-blades {

  file {
    '/mnt/yow-blades':
      ensure => directory,
      owner  => root,
      group  => root;
  }

  mount {
    '/mnt/yow-blades':
      ensure   => unmounted,
      atboot   => true,
      device   => 'yow-lpgnas2:/vol/vol1',
      fstype   => nfs,
      options  => 'rw,_netdev',
      require  => File['/mnt/yow-blades'],
      remounts => true;
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
