#
class profile::consul {

  file {
    '/opt':
      ensure => directory;
  }

  # Puppet is not detecting systemd on Debian 8 properly
  if $::operatingsystem == 'Debian' and $::operatingsystemmajrelease > '7' {
    Service { provider => 'systemd' }
  }

  # Puppet is not detecting systemd on OpenSuSE 12.3 properly
  if $::operatingsystem == 'OpenSuSE' {
    Service { provider => 'systemd' }
  }

  class {
    '::consul':
      config_hash => hiera_hash('consul_config_hash');
  }
}
