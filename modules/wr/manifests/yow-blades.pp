#
class wr::yow-blades {

  include profile::monitored

  include yocto
  include nx
  include collectd

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
  include ssmtp

  #make sure ssmtp is installed before
  #to ensure the alternatives links are setup properly
  package {
    'sendmail':
      ensure => absent;
  }
  Package['ssmtp'] -> Package['sendmail']

  class {
    'smart':
      devices  => ['/dev/sg0', '/dev/sg1',];
  }
}
