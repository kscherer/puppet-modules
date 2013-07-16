#The common configuration for all systems
class profile::base {
  include dns
  Class['dns'] -> Class['wr::common::repos']

  include motd
  include ntp
  include wr::common::repos
  include wr::common::ssh_root_keys
  include wr::common::etc_host_setup
  include wr::common::bash_configs
  include wr::workaround::xen
  include puppet

  #make sure classes the may install packages come after repo info is updated
  Class['wr::common::repos'] -> Class['ntp']
  Class['wr::common::repos'] -> Class['puppet']
}

#
class profile::monitored inherits profile::base {
  include nrpe
  include wr::mcollective
  include nagios::target

  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['wr::mcollective']
  Class['wr::common::repos'] -> Class['nagios::target']
}

#
class profile::git::base inherits profile::monitored {

  if $::operatingsystem == 'CentOS' {
    include redhat::autoupdate
    Class['wr::common::repos'] -> Class['redhat::autoupdate']
  }

  include git::service
  include git::wr_bin_repo
  include nis
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

  Class['wr::common::repos'] -> Class['git']
  Class['wr::common::repos'] -> Class['nis']
  Class['wr::common::repos'] -> Class['sudo']
}

#
class profile::git::master inherits profile::git::base {
  include git::grokmirror::master
}

#
class profile::git::mirror inherits profile::git::base {
  include git::grokmirror::mirror
}
