#
class nx::ala-blades {

  case $::hostname {
    /ala-blade2[5-9]/: {
      include nx::ala_local_build
      nx::setup { '1': }
    }
    /ala-blade3[0-2]/: {
      include nx::ala_local_build
      nx::setup { '1': }
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

  mount {
    '/stored_builds':
      ensure   => mounted,
      atboot   => true,
      device   => 'ala-lpgnas2-nfs:/vol/stored_builds_25',
      fstype   => 'nfs',
      options  => $options,
      remounts => true;
  }
}

class nx::ala_local_build {

  $local_builddir = "/${::hostname}1"

  file {
    $local_builddir:
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    "${local_builddir}/nxadm":
      ensure  => directory,
      mode    => '0755';
    "${local_builddir}/nxadm/nx":
      ensure  => directory,
      require => File["$local_builddir/nxadm"],
      mode    => '0755';
    '/home/nxadm/nx':
      ensure  => link,
      target  => "${local_builddir}/nxadm/nx";
    "${local_builddir}/nxadm/nx/${::hostname}.1":
      ensure  => directory,
      mode    => '0755';
  }
}
