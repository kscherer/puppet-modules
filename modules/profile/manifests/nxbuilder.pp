#
class profile::nxbuilder inherits profile::nis {

  if $::hostname != 'ala-blade1' {
    include nx
  }
  include yocto
  Class['wr::common::repos'] -> Class['yocto']

  include git
  Class['wr::common::repos'] -> Class['git']

  motd::register{
    'nxbuilder':
      content => 'This machine is reserved for WR Linux coverage builds.';
  }

  if 'blade' in $::hostname {
    user {
      'root':
        password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
    }
    #setup ssmtp to forward all email sent to root to Konrad
    include ssmtp
    include collectd
  }

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease == '5' {
    #this package is needed for Dell bios upgrade software
    package {
      ['libxml2.i386','compat-libstdc++-33.i386']:
        ensure => installed;
    }

    #unnecesary services
    service {
      ['iscsi','iscsid']:
        ensure => stopped,
        enable => false;
    }
  }

  if $::hostname == 'ala-blade48' {
    include docker
    group {
      'docker':
        ensure  => present,
        members => ['users'],
        require => Class['docker'];
    }
  }
}
