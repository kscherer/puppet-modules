#
class role::git::master inherits role {
  include git
  include nis

  include nrpe
  include nagios::target
  include profile::bare_metal

  Class['wr::common::repos'] -> Class['nrpe']
  Class['wr::common::repos'] -> Class['nagios::target']
  Class['wr::common::repos'] -> Class['git']
  Class['wr::common::repos'] -> Class['nis']
  Class['wr::common::repos'] -> Class['profile::bare_metal']
}
