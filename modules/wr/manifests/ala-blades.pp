#
class wr::ala-blades inherits wr::ala-common {

  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
  }

  #buildadmin user is a nis account, but without a nfs home directory.
  file {
    '/home/buildadmin':
      ensure => directory,
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755';
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
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('pkennedy@linux-y9cs.site'),
      type   => 'ssh-dss';
    'wenzong_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('wfan@pek-wenzong-fan'),
      type   => 'ssh-dss';
    'kscherer_windriver_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('kscherer@yow-kscherer-l1'),
      type   => 'ssh-dss';
    'kscherer_home_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('kscherer@helix'),
      type   => 'ssh-rsa';
  }

  motd::register{
    'ala-blade':
      content => 'This machine is reserved for WR Linux release and coverage builds.';
  }
}
