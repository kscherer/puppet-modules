#install nomachine nx for usable X forwarding over WAN
class nomachine {
  if $::osfamily == 'RedHat' {
    redhat::yum_repo {
      'nomachine':
        ensure => absent,
        baseurl => 'http://yow-mirror.wrs.com/mirror/nomachine';
    }
    Yumrepo['nomachine'] -> Package['nxserver']
  }

  package {
    ['nxserver']:
      ensure => absent;
  }

  service {
    'nxserver':
      ensure    => stopped,
      enable    => true,
      status    => '/usr/NX/bin/nxserver --status',
      hasstatus => true;
  }

  Package['nxserver'] -> Service['nxserver']
}
