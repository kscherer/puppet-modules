#Run internal docker registry
class profile::docker::registry {
  include docker

  #run registry as docker container of course
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
      command => ' ',
      ports   => ['5000:5000'],
      volumes => ['/opt/registry:/registry'],
      env     => ['DOCKER_REGISTRY_CONFIG=/registry/config.yml','SETTINGS_FLAVOR=prod'],
      require => [ File['/opt/registry/store'], File['/opt/registry/config.yml']];
  }
}
