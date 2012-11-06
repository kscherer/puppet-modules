#
class nx::ala-lpd-test {

  case $::hostname {
    'ala-lpd-test3': { nx::setup { ['1','2','3']: } }
    default: {  nx::setup { ['1','2']: } }
  }

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
    [ "/home/nxadm/nx/${::hostname}.1", "/home/nxadm/nx/${::hostname}.2",
      "/home/nxadm/nx/${::hostname}.3" ]:
      ensure  => directory,
      owner   => 'nxadm',
      group   => 'nxadm',
      mode    => '0755';
  }
}
