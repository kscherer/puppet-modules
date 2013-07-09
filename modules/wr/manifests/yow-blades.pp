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

  #unnecesary services
  service {
    ['iscsi','iscsid']:
      ensure => stopped,
      enable => false;
  }

  #setup ssmtp to forward all email sent to root to Konrad
  class {
    'ssmtp':
      mailhub => 'mail.windriver.com',
      root    => 'konrad.scherer@windriver.com';
  }

  #make sure sendmail is not on the machine and ssmtp is installed afterwards
  #to ensure the alternatives links are setup properly
  package {
    'sendmail':
      ensure => absent;
  }
  Package['sendmail'] -> Package['ssmtp']

  #monitor
  class {
    'smart':
      devices    => ['/dev/sg0', '/dev/sg1',],
      email      => 'konrad.scherer@windriver.com',
      scheldule  => '(S/../.././02|L/../../6/03)';
  }
}
