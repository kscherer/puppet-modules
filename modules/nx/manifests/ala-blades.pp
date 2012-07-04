#
class nx::ala-blades {

  #create nx instances
  nx::setup {
    '1':
  }

  $local_builddir = "/${::hostname}1"

  file {
    $local_builddir:
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    "${local_builddir}/nxadm":
      ensure  => directory,
      require => Mount[$local_builddir],
      mode    => '0755';
    "${local_builddir}/nxadm/nx":
      ensure  => directory,
      require => File["$local_builddir/nxadm"],
      mode    => '0755';
    '/home/nxadm/nx':
      ensure  => link,
      target  => "${local_builddir}/nxadm/nx",
      replace => false;
    "${local_builddir}/nxadm/nx/${::hostname}.1":
        ensure  => directory,
        mode    => '0755',
        replace => false;
  }
}
