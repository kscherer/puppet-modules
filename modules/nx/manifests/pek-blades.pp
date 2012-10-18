#
class nx::ala-blades {

  include nx::local_build
  nx::setup { ['1','2']: }

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
