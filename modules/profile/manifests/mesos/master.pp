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

  #mandatory configuration options for 0.19
  file {
    '/etc/mesos-master/work_dir':
      content => '/var/lib/mesos/';
    '/etc/mesos-master/quorum':
      content => '1';
  }
}
