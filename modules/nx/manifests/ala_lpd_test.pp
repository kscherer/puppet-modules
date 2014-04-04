#
class nx::ala_lpd_test {
  nx::setup { '1': }

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
    "/home/nxadm/nx/${::hostname}.1":
      ensure  => directory,
      owner   => 'nxadm',
      group   => 'nxadm',
      mode    => '0755';
  }
}
