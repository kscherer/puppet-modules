#
class profile::mesos::common inherits profile::nis {

  file {
    '/usr/lib/libjvm.so':
      ensure => link,
      target => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/libjvm.so';
  }

  package {
    ['openjdk-7-jre-headless','python-setuptools']:
      ensure  => present,
      require => Class['wr::common::repos'];
  }

  Class['wr::common::repos'] -> Class['mesos']
  Package['openjdk-7-jre-headless'] -> File['/usr/lib/libjvm.so'] -> Package['mesos']

  #add internal apt repo of mesosphere packages
  apt::key {
    'wr_mesos':
      key        => '624C1ADB',
      key_source => 'http://yow-mirror.wrs.com/mirror/mesos/mesos.gpg',
  }
  apt::source {
    'mesos':
      location    => 'http://yow-mirror.wrs.com/mirror/mesos',
      release     => $::lsbdistcodename,
      repos       => 'main',
      include_src => false,
      require     => Apt::Key['wr_mesos'];
  }
  Apt::Source['mesos'] -> Package['mesos']

  #install mesos egg
  $mesos_egg = 'mesos_0.18.0_amd64.egg'

  exec {
    'mesos_egg':
      command => "/usr/bin/wget -O /root/${mesos_egg} \
                  http://${::location}-mirror.wrs.com/mirror/mesos/${mesos_egg}",
      creates => "/root/${mesos_egg}";
    'install_mesos_egg':
      command => "/usr/bin/easy_install /root/${mesos_egg}",
      unless  => "/usr/bin/test -f /usr/local/lib/python2.7/dist-packages/${mesos_egg}",
      require => [ Package['python-setuptools'], Exec['mesos_egg']];
  }
}
