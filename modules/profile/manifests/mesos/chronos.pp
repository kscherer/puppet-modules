#Run chronos
class profile::mesos::chronos {

  apt::source { 'mesosphere':
    location    => 'http://repos.mesosphere.io/ubuntu',
    repos       => 'main',
    include_src => false,
    key         => 'E56151BF',
    key_server  => 'keyserver.ubuntu.com';
  }

  package {
    'chronos':
      ensure => latest,
      require => Apt::Source['mesosphere'];
  }

  service {
    'chronos':
      ensure     => stopped,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider   => upstart,
      require    => Package['chronos'];
  }
}
