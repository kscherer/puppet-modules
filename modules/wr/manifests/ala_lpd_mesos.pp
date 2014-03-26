#System responsible for mesos master, chronus, zookeeper and private
#docker registry
class wr::ala_lpd_mesos {
  include profile::nis
  include ssmtp
  include docker
  include collectd

  #setup for the docker registry
  docker::image {
    'registry':
      image_tag => 'latest';
    'jplock/zookeeper':
      image_tag => 'latest';
    'ala-lpd-mesos.wrs.com:5000/mesos_master':
      image_tag => '17';
  }

  #store all registry info in /opt
  file {
    '/opt/registry':
      ensure => directory;
    '/opt/registry/store':
      ensure => directory;
    '/opt/registry/config.yml':
      ensure => present,
      source => 'puppet:///modules/wr/docker_registry_config.yml';
  }

  #Run the registry image with bind mount to registry directory and config
  #As of Mar 26, docker index was out of date and I added the commands to
  #update the git repo inside the image
  docker::run {
    'registry':
      image   => 'registry',
      command => '/bin/sh -c \'cd /docker-registry && git remote add origin https://github.com/dotcloud/docker-registry.git && git pull origin master && ./setup-configs.sh && exec ./run.sh\'',
      ports   => ['5000:5000'],
      volumes => ['/opt/registry:/registry'],
      env     => ['DOCKER_REGISTRY_CONFIG=/registry/config.yml','SETTINGS_FLAVOR=prod'],
      require => [ File['/opt/registry/store'], File['/opt/registry/config.yml']];
    'zookeeper':
      image   => 'jplock/zookeeper:latest',
      command => ' ',
      ports   => ['2181:2181','2888:2888','3888:3888'];
    'mesos_master':
      image   => 'ala-lpd-mesos.wrs.com:5000/mesos_master:17',
      command => 'mesos-master --quiet --zk=zk://ala-lpd-mesos.wrs.com:2181/mesos',
      ports   => ['5050:5050'];
  }
}
