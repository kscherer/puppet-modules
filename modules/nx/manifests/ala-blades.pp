#
class nx::ala-blades {

  include nx::local_build
  nx::setup { ['1','2']: }

  host {
    'ala-lpgnas1-nfs':
      ip           => '172.17.136.110',
      host_aliases => 'ala-lpgnas1-nfs.wrs.com';
    'ala-lpgnas2-nfs':
      ip           => '172.17.136.114',
      host_aliases => 'ala-lpgnas2-nfs.wrs.com';
  }

  case $::hostname {
    ala-blade17: { $options='rw' }
    ala-blade25: { $options='rw' }
    default: { $options='ro' }
  }

  file {
    '/stored_builds':
      ensure => directory,
      owner  => 'buildadmin',
      group  => 'buildadmin',
  }

  mount {
    '/stored_builds':
      ensure   => mounted,
      atboot   => true,
      device   => 'ala-lpgnas2-nfs:/vol/stored_builds_25',
      fstype   => 'nfs',
      options  => $options,
      require  => File['/stored_builds'],
      remounts => true;
  }
}
