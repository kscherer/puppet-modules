#
class profile::mesos::master inherits profile::mesos::common {
  include ::mesos::master
  include docker

  Class['wr::common::repos'] -> Class['docker']
}
