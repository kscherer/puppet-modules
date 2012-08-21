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
    yow-blade1: { include nx::yow_local_build }
    /^yow-blade[2-8]$/: { include nx::netapp_iscsi_setup }
    yow-blade9: { include nx::md3000_iscsi_setup }
    /^yow-blade1[0-6]$/: { include nx::md3000_iscsi_setup }
    default: { fail("Do not know how to configure nx for $::hostname")}
  }
}

class nx::yow_local_build {

  $local_builddir = '/test'

  file {
    $local_builddir:
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    "${local_builddir}/nxadm":
      ensure  => directory,
      mode    => '0755';
    "${local_builddir}/nxadm/nx":
      ensure  => directory,
      require => File["$local_builddir/nxadm"],
      mode    => '0755';
    '/home/nxadm/nx':
      ensure  => link,
      target  => "${local_builddir}/nxadm/nx";
    "${local_builddir}/nxadm/nx/${::hostname}.1":
      ensure  => directory,
      mode    => '0755';
    "${local_builddir}/nxadm/nx/${::hostname}.2":
      ensure  => directory,
      mode    => '0755';
  }
}
