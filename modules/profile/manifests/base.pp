#
class profile::base {
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
class profile::git::base {
  include nrpe
  include wr::mcollective
  include git::service
  include git::wr_bin_repo
  Class['wr::common::repos'] -> Class['git']
  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['wr::mcollective']
}

#
class profile::git::master inherits profile::git::base {
  include git::grokmirror::master
}

#
class profile::git::mirror inherits profile::git::base {
  include git::grokmirror::mirror
}