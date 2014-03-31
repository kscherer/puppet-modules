#
class profile::mesos::slave inherits profile::mesos::common {
  include mesos::slave
  include docker

  File['/usr/lib/libjvm.so'] -> Package['mesos']
  Apt::Source['mesos'] -> Package['mesos']

  docker::image {
    'ala-lpd-mesos.wrs.com:5000/centos5_32':
      image_tag => 'wrl';
    'ala-lpd-mesos.wrs.com:5000/centos5_64':
      image_tag => 'wrl';
  }
}
