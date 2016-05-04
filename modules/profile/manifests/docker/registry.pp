#Run internal docker registry
class profile::docker::registry {
  include ::profile::docker

  #run registry as docker container of course
  docker::image {
    'registry':
      image_tag => '2';
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

  docker::run {
    'registry2':
      image   => 'registry:2',
      command => ' ',
      ports   => ['5000:5000'],
      volumes => ['/opt/registry:/registry',
                  '/opt/registry/config2.yml:/etc/docker/registry/config.yml'],
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
