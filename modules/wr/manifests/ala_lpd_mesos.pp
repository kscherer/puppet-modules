#System responsible for mesos master, chronus, zookeeper and private
#docker registry
class wr::ala_lpd_mesos {
  include profile::mesos::master
  include ssmtp
  include collectd

  #setup for the docker registry
  docker::image {
    'registry':
      image_tag => 'latest';
    'jplock/zookeeper':
      image_tag => 'latest';
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
    '/etc/init/chronos.conf':
      ensure => present,
      source => 'puppet:///modules/wr/chronos.conf',
      notify => Service['chronos'];
  }

  service {
    'chronos':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider   => upstart;
  }

  #Run the registry image with bind mount to registry directory and config
  #As of Mar 26, docker index was out of date and I added the commands to
  #update the git repo inside the image
  docker::run {
    'registry':
      image   => 'registry',
      command => ' ',
      ports   => ['5000:5000'],
      volumes => ['/opt/registry:/registry'],
      env     => ['DOCKER_REGISTRY_CONFIG=/registry/config.yml','SETTINGS_FLAVOR=prod'],
      require => [ File['/opt/registry/store'], File['/opt/registry/config.yml']];
    'zookeeper':
      image   => 'jplock/zookeeper:latest',
      command => ' ',
      ports   => ['2181:2181','2888:2888','3888:3888'];
  }
}
