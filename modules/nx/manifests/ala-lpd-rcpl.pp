#
class nx::ala-lpd-rcpl {
  nx::setup { ['1','2']: }

  file {
    '/data/nxadm':
      ensure => directory,
      mode   => '0755',
      owner  => 'nxadm',
      group  => 'nxadm';
    '/buildarea':
      ensure => link,
      target => '/data/';
    '/buildarea/nxadm/nx':
      ensure  => directory,
      owner   => 'nxadm',
      group   => 'nxadm',
      require => File['/data/nxadm'],
      mode    => '0755';
    '/home/nxadm/nx':
      ensure  => link,
      target  => '/buildarea/nxadm/nx';
    "/buildarea/nxadm/nx/${::hostname}.1":
      ensure  => directory,
      owner   => 'nxadm',
      group   => 'nxadm',
      mode    => '0755';
    "/buildarea/nxadm/nx/${::hostname}.2":
      ensure  => directory,
      owner   => 'nxadm',
      group   => 'nxadm',
      mode    => '0755';
  }
}
