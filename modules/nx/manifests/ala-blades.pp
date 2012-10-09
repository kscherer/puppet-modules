#
class nx::ala-blades {

  case $::hostname {
    /ala-blade2[5-9]/: {
      include nx::ala_local_build
      nx::setup { '1': }
    }
    'ala-blade30': {
      include nx::ala_local_build
      nx::setup { '1': }
    }
    'ala-blade31': {
      include nx::netapp_iscsi_setup
      nx::setup { ['1','2']: }
    }
    'ala-blade32': {
      include nx::local_build
      nx::setup { ['1','2']: }
    }
    default: { fail("Do not know how to configure nx for $::hostname")}
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
    ala-blade25: { $options='rw' }
    default: { $options='ro' }
  }

  file {
    '/stored_builds':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
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
