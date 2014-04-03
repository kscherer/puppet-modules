#
class profile::mesos::master inherits profile::mesos::common {
  include ::mesos::master
  include docker

  Class['wr::common::repos'] -> Class['docker']

  file {
    '/etc/init/mesos-slave.override':
      ensure  => present,
      content => 'manual';
  }
}
