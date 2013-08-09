#install nomachine nx for usable X forwarding over WAN
class nomachine {
  if $::osfamily == 'RedHat' {
    redhat::yum_repo {
      'nomachine':
        baseurl => 'http://yow-mirror.wrs.com/mirror/nomachine';
    }
    Yumrepo['nomachine'] -> Package['nxserver']
  }

  package {
    'nxserver':
      ensure => installed;
  }

  service {
    'nxserver':
      ensure    => running,
      enable    => true,
      status    => '/usr/NX/bin/nxserver --status',
      hasstatus => true;
  }

  Package['nxserver'] -> Service['nxserver']
}
