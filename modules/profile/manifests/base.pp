#The common configuration for all systems
class profile::base {
  include wr::dns
  Class['wr::dns'] -> Class['wr::common::repos']

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

  #enable autoupdate on all CentOS systems
  if $::operatingsystem == 'CentOS' {
    include redhat::autoupdate
    Class['wr::common::repos'] -> Class['redhat::autoupdate']
  }
}

#
class profile::git::base inherits profile::nis {

  include git::service
  Class['wr::common::repos'] -> Class['git']
}

#
class profile::git::master inherits profile::git::base {
  include git::grokmirror::master
}

#
class profile::git::mirror inherits profile::git::base {
  include git::wr_bin_repo
  include git::grokmirror::mirror
}
