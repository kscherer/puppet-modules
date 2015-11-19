#
class profile::consul {

  file {
    '/opt':
      ensure => directory;
  }

  class {
    '::consul':
      config_hash => hiera_hash('consul_config_hash');
  }
}
