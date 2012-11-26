#
class wr::ala-blades inherits wr::ala-common {

  class { 'dell': }

  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
  }

  #for now there are still a few machines that have not been moved to local disk yet
  case $::hostname {
    /^ala-blade[1-8]$/: { include nx }
    /ala-blade(1[7-9]|2[0-9]|3[0-2])/: { include nx }
    default: {}
  }

  #buildadmin user is a nis account, but without a nfs home directory.
  file {
    '/home/buildadmin':
      ensure  => directory,
      owner   => 'buildadmin',
      group   => 'buildadmin',
      require => Class['nis'],
      mode    => '0755';
    '/home/buildadmin/.ssh':
      ensure => directory,
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0700';
  }

  ssh_authorized_key {
    'root@ala-blade9':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade9'),
      type   => 'ssh-rsa';
    'root@ala-blade14':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade14'),
      type   => 'ssh-dss';
    'root@ala-blade17':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade17'),
      type   => 'ssh-rsa';
    'root@ala-blade25':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade25'),
      type   => 'ssh-rsa';
    'pkennedy_buildadmin':
      ensure  => 'present',
      user    => 'buildadmin',
      key     => extlookup('pkennedy@linux-y9cs.site'),
      require => File['/home/buildadmin/.ssh'],
      type    => 'ssh-dss';
    'wenzong_buildadmin':
      ensure  => 'present',
      user    => 'buildadmin',
      key     => extlookup('wfan@pek-wenzong-fan'),
      require => File['/home/buildadmin/.ssh'],
      type    => 'ssh-dss';
    'kscherer_windriver_buildadmin':
      ensure  => 'present',
      user    => 'buildadmin',
      key     => extlookup('kscherer@yow-kscherer-l1'),
      require => File['/home/buildadmin/.ssh'],
      type    => 'ssh-dss';
    'kscherer_home_buildadmin':
      ensure  => 'present',
      user    => 'buildadmin',
      key     => extlookup('kscherer@helix'),
      require => File['/home/buildadmin/.ssh'],
      type    => 'ssh-rsa';
  }

  motd::register{
    'ala-blade':
      content => 'This machine is reserved for WR Linux release and coverage builds.';
  }

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
  }

  host {
    'ala-lpgnas1-nfs':
      ip           => '172.17.136.110',
      host_aliases => 'ala-lpgnas1-nfs.wrs.com';
    'ala-lpgnas2-nfs':
      ip           => '172.17.136.114',
      host_aliases => 'ala-lpgnas2-nfs.wrs.com';
  }

  case $::hostname {
    ala-blade1: { $options='mounted' }
    ala-blade9: { $options='mounted' }
    default: { $options='absent' }
  }

  file {
    '/stored_builds':
      ensure  => directory,
      owner   => 'buildadmin',
      group   => 'buildadmin',
      require => Class['nis'],
  }

  mount {
    '/stored_builds':
      ensure   => $options,
      atboot   => true,
      device   => 'ala-lpgnas2-nfs:/vol/vol1',
      fstype   => 'nfs',
      options  => 'bg,vers=3,nointr,timeo=600,_netdev',
      require  => File['/stored_builds'],
      remounts => true;
  }

  #some packages needed to run Xylo
  package {
    ['perl-XML-Simple','perl-XML-Twig','cvs']:
      ensure => installed;
  }
}
