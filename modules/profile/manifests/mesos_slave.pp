#
class profile::mesos_slave inherits profile::monitored {
  include mesos::slave
  include docker

  docker::image {
    'ala-lpd-mesos.wrs.com:5000/centos5_32':
      image_tag => 'wrl';
    'ala-lpd-mesos.wrs.com:5000/centos5_64':
      image_tag => 'wrl';
  }

  file {
    '/usr/lib/libjvm.so':
      ensure => link,
      target => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/libjvm.so';
  }

  package {
    'openjdk-7-jre-headless':
      ensure => present;
  }

  Package['openjdk-7-jre-headless'] -> File['/usr/lib/libjvm.so'] -> Class['mesos::slave']
}
