#
class profile::consul {

  file {
    '/opt':
      ensure => directory;
    '/usr/local/bin/consul':
      ensure => link,
      target => '/opt/consul/consul';
  }

  # Puppet is not detecting systemd on Debian 8 properly
  if $::operatingsystem == 'Debian' and $::operatingsystemmajrelease > '7' {
    Service { provider => 'systemd' }
  }

  # Puppet is not detecting systemd on OpenSuSE 12.3 properly
  if $::operatingsystem == 'OpenSuSE' {
    Service { provider => 'systemd' }
  }

  # Require unzip to install consul packages
  ensure_packages(['unzip'])

  class {
    '::consul':
      config_hash => hiera_hash('consul_config_hash');
  }
}
