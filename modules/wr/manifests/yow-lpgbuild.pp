#
class wr::yow-lpgbuild inherits wr::yow-common {

  Class['redhat'] -> Class['yocto']

  class { 'yocto': }
  -> class { 'nx': }

  user {
    'root':
      password => '$6$p6ikdyj/GHN7Uno3$VDlbq91Mp5osT0yLxVTbtDhhidFYTK7r/2xM5426g6bbesNzfhaXditRBSieRwsgpNJIbYEQhA7SZcXdf.VcZ0';
  }

  ssh_authorized_key {
    'kscherer_windriver_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('kscherer@yow-kscherer-l1'),
      type   => 'ssh-dss';
    'kscherer_home_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('kscherer@helix'),
      type   => 'ssh-rsa';
    'jwessel_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('jwessel@splat'),
      type   => 'ssh-rsa';
  }
  motd::register{
    'yow-lpgbuild':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }
}
