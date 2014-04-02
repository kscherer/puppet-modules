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

  #The mesos package can start the mesos master so make sure it is
  #not running on slaves
  service {
    'mesos-master':
      ensure => stopped;
  }

  # Do builds as an unprivileged user which matches uid of user in docker
  group {
    'wrlinux':
      ensure => present,
  }

  user {
    'wrlinux':
      ensure     => present,
      gid        => 'wrlinux',
      uid        => 1000,
      managehome => true,
      home       => '/home/wrlinux',
      shell      => '/bin/bash',
      password   => '$5$6F1BpKqFcszWi0n$fC5yUBkPNXHfyL8TOJwdJ1EE8kIzwJnKVrtcFYnpbcA',
      require    => Group [ 'wrlinux' ];
  }

  #turn off locate package which scans filesystem and use a lot of IO
  ensure_resource('package', 'mlocate', {'ensure' => 'absent' })
}
