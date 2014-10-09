#Run chronos
class profile::mesos::chronos {

  apt::source { 'mesosphere':
    location   => 'http://repos.mesosphere.io/ubuntu',
    repos      => 'trusty',
    key        => 'E56151BF',
    key_server => 'keyserver.ubuntu.com';
  }

  package {
    'chronos':
      ensure => latest,
      require => Apt::Source['mesosphere'];
  }

  service {
    'chronos':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider   => upstart,
      require    => Package['chronos'];
  }
}
