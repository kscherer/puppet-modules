#
class nx::netapp_iscsi_setup {

  class{ 'iscsi::netapp': }
  -> Anchor['nx::begin']
  -> Class['nx::netapp_iscsi_setup']
  -> Class["nx::${::location}-blades"]
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
      target  => '/buildarea/nxadm/nx';
    [ "/buildarea/nxadm/nx/${::hostname}.1",
      "/buildarea/nxadm/nx/${::hostname}.2"]:
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
