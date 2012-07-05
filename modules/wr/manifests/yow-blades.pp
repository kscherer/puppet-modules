#
class wr::yow-blades inherits wr::yow-common {

  Class['redhat'] -> Class['yocto']

  class { 'yocto': }
  -> class { 'nx': }

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
  }

  motd::register{
    'yow-blade':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }
}
