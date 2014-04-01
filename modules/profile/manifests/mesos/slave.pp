#
class profile::mesos::slave inherits profile::mesos::common {
  include ::mesos::slave
  include docker
  Class['wr::common::repos'] -> Class['docker']

  docker::image {
    'ala-lpd-mesos.wrs.com:5000/centos5_32':
      image_tag => 'wrl',
      require   => Class['docker'];
    'ala-lpd-mesos.wrs.com:5000/centos5_64':
      image_tag => 'wrl',
      require   => Class['docker'];
  }
}
