#Run internal docker registry
class profile::docker::registry {
  include ::docker

  apt::source {
    'wr-docker':
      location     => "http://${::location}-mirror.wrs.com/mirror/apt/apt.dockerproject.org/repo/",
      release      => "ubuntu-${::lsbdistcodename}",
      repos        => 'main',
      architecture => 'amd64',
      include_src  => false,
      key          => '58118E89F3A912897C070ADBF76221572C52609D',
      key_server   => 'hkp://pgp.mit.edu:80';
  }

  package {
    'docker-engine':
      ensure  => '1.8.3-0~trusty';
  }
  Apt::Source['wr-docker'] -> Package['docker-engine']

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
    '/opt/registry/store2':
      ensure => directory;
    '/opt/registry/proxy':
      ensure => directory;
    '/opt/registry/config.yml':
      ensure => present,
      source => 'puppet:///modules/wr/docker_registry_config.yml';
    '/opt/registry/config2.yml':
      ensure => present,
      source => 'puppet:///modules/wr/docker_registry_config2.yml';
    '/opt/registry/proxy.yml':
      ensure => present,
      source => 'puppet:///modules/wr/docker_registry_proxy.yml';
  }

  #Run the registry image with bind mount to registry directory and config
  docker::run {
    'registry':
      image   => 'registry',
      command => ' ',
      ports   => ['5000:5000'],
      volumes => ['/opt/registry:/registry'],
      env     => ['DOCKER_REGISTRY_CONFIG=/registry/config.yml','SETTINGS_FLAVOR=prod'],
      require => [File['/opt/registry/store'], File['/opt/registry/config.yml'],
                  Service['docker']];
  }

  docker::run {
    'registry2':
      image   => 'registry:2',
      command => ' ',
      ports   => ['5500:5000'],
      volumes => ['/opt/registry:/registry',
                  '/opt/registry/docker_registry_config2.yml:/etc/docker/registry/config.yml'],
      require => [File['/opt/registry/store2'], File['/opt/registry/config2.yml'],
                  Service['docker']];
  }

  # Docker registry 2.1 supports proxy cache for docker hub, but not for registries
  # that accept pushes. So the proxy cache has to have different config and be on different port
  docker::run {
    'hub-proxy':
      image   => 'registry:2',
      command => ' ',
      ports   => ['6000:5000'],
      volumes => ['/opt/registry:/registry',
                  '/opt/registry/proxy.yml:/etc/docker/registry/config.yml'],
      require => [File['/opt/registry/proxy'], File['/opt/registry/proxy.yml'],
                  Service['docker']];
  }

}
