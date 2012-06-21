#
class wr::yow-blades inherits wr::yow-common {

  Class['redhat'] -> Class['yocto']

  class { 'yocto': }
  -> class { 'nx': }

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
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
    'yow-blade':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }
}
