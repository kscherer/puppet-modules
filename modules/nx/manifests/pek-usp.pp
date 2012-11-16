#
class nx::pek-usp {

  file {
    '/buildarea/nx':
      ensure  => directory,
      owner  => 'nxadm',
      group  => 'nxadm',
      mode    => '0755';
    "/home/nxadm/nx":
      ensure => link,
      target => '/buildarea/nx';
    ["/home/nxadm/nx/${::hostname}.1"]:
      ensure  => directory,
      mode    => '0755';
  }

  nx::setup { ['1']: }
}
