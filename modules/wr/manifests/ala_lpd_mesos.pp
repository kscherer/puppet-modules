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
  docker::run {
    'registry':
      image   => 'registry',
      command => 'cd /docker-registry && ./setup-configs.sh && exec ./run.sh',
      ports   => ['5000:5000'],
      volumes => ['/opt/registry:/registry'],
      env     => ['DOCKER_REGISTRY_CONFIG=/registry/config.yml'],
      require => [ File['/opt/registry/store'], File['/opt/registry/config.yml']];
  }
}
