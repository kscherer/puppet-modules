#
class profile::consul {

  file {
    '/opt':
      ensure => directory;
  }

  # Puppet is not detecting systemd on Debian 8 properly
  if $::operatingsystem == 'Debian' {
    Service {provider => 'systemd'}
  }

  class {
    '::consul':
      config_hash => hiera_hash('consul_config_hash');
  }
}
