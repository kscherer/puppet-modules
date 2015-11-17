#
class profile::consul {

  class {
    '::consul':
      config_hash => hiera_hash('consul_config_hash');
  }
}
