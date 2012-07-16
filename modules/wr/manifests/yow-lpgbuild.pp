#
class wr::yow-lpgbuild inherits wr::yow-common {

  Class['redhat'] -> Class['yocto']

  class { 'yocto': }
  -> class { 'nx': }

  user {
    'root':
      password => '$6$p6ikdyj/GHN7Uno3$VDlbq91Mp5osT0yLxVTbtDhhidFYTK7r/2xM5426g6bbesNzfhaXditRBSieRwsgpNJIbYEQhA7SZcXdf.VcZ0';
  }

  motd::register{
    'yow-lpgbuild':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }
}
