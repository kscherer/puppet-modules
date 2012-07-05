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
    [ "/ba1/${::hostname}.1",
      "/ba2/${::hostname}.2" ]:
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
  }
}
