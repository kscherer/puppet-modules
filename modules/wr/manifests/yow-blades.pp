#
class wr::yow-blades {

  include dell
  Class['redhat'] -> Class['yocto']

  class { 'wr::yow-common': }
  -> class { 'yocto': }
  -> class { 'nx': }
  -> class{ 'collectd': }

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
  }

  motd::register{
    'yow-blade':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }

  #this package is needed for Dell bios upgrade software
  package {
    'libxml2.i386':
      ensure => installed;
  }

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
  }

  #unnecesary services
  service {
    ['iscsi','iscsid']:
      ensure => stopped,
      enable => false;
  }

  #concat is another possible extension point
  concat::fragment {
    'cpu-aggregrate':
      target  => '/etc/carbon/aggregation-rules.conf',
      order   => 0,
      source  => 'puppet:///modules/wr/cpu-aggregation.conf',
      before  => Concat['/etc/carbon/aggregation-rules.conf'];
  }
}
