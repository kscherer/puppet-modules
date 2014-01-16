#
class profile::git::base inherits profile::nis {

  include git::service
  Class['wr::common::repos'] -> Class['git']
}
