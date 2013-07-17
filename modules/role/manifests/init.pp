#
class role {
  include profile::base
}

#
class role::git::master inherits role {
  include git
  include nis

  Class['wr::common::repos'] -> Class['git']
  Class['wr::common::repos'] -> Class['nis']
}

#
class role::git::mirror inherits role {
  include profile::git::mirror
}


