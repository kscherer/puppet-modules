#install nomachine nx for usable X forwarding over WAN
class nomachine {
  if $::osfamily == 'RedHat' {
    yumrepo {
      'nomachine':
        baseurl => 'http://yow-mirror.wrs.com/mirror/nomachine',
        descr   => 'Local mirror of nomachine packages';
    }
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
}
