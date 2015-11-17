#
class profile::consul {

  file {
    '/opt/consul':
      ensure => directory,
      owner => 'consul',
      group => 'consul',
      mode  => '0755';
  }

  File['/opt/consul'] -> Class['::consul']

  class {
    '::consul':
      config_hash => hiera_hash('consul_config_hash');
  }
}
