#
class wr::pek-blades inherits wr::pek-common {

  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
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
    'pek-blade':
      content => 'This machine is reserved for WR Linux release and coverage builds.';
  }

  host {
    'pek-lpgnas1':
      ip           => '128.224.152.129',
      host_aliases => 'pek-lpgnas1.wrs.com';
  }

  case $::hostname {
    pek-blade17: { $options='rw' }
    default: { $options='ro' }
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
      ensure   => mounted,
      atboot   => true,
      device   => 'pek-lpgnas1:/vol/stored_builds',
      fstype   => 'nfs',
      options  => $options,
      require  => File['/stored_builds'],
      remounts => true;
  }
}
