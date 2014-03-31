#
class profile::mesos::common inherits profile::nis {

  file {
    '/usr/lib/libjvm.so':
      ensure => link,
      target => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/libjvm.so';
  }

  package {
    'openjdk-7-jre-headless':
      ensure => present;
  }

  Package['openjdk-7-jre-headless'] -> File['/usr/lib/libjvm.so'] -> Class['mesos']

  #add internal apt repo of mesosphere packages
  apt::source {
    'mesos':
      location    => 'http://yow-mirror.wrs.com/mirror/mesos',
      release     => $::lsbdistcodename,
      repos       => 'main',
      include_src => false;
  }
  Apt::Source['mesos'] -> Class['mesos']

  #install mesos egg
  $mesos_egg = 'mesos_0.18.0-rc4_amd64.deb'

  exec {
    'mesos_egg':
      command => "wget -O /root/${mesos_egg} http://yow-mirror.wrs.com/mirror/mesos/${mesos_egg} --no-check-certificate",
      creates => "/root/${mesos_egg}";
    'install_mesos_egg':
      command => "easy_install /root/${mesos_egg}",
      unless  => "test -d /usr/local/lib/python2.7/dist-packages/${mesos_egg}",
      require => Exec['mesos_egg'];
  }
}
