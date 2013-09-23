#
class role {
  include profile::base
}

#
class role::git::master inherits role {
  include git
  include nis

  include nrpe
  include nagios::target

  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['nagios::target']
  Class['wr::common::repos'] -> Class['git']
  Class['wr::common::repos'] -> Class['nis']
}

#
class role::git::mirror inherits role {
  include profile::git::mirror
}

#
class role::provisioner {
  include profile::nis
}
