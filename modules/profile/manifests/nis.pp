#
class profile::nis inherits profile::monitored {

  include sudo

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
    'leads':
      source  => 'puppet:///modules/wr/sudoers.d/leads';
    'it':
      source  => 'puppet:///modules/wr/sudoers.d/it';
    'scmg':
      source  => 'puppet:///modules/wr/sudoers.d/scmg';
  }

  include nis

  Class['wr::common::repos'] -> Class['nis']
  Class['wr::common::repos'] -> Class['sudo']
}
