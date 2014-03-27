#
class profile::mesos_slave inherits profile::monitored {
  include mesos::slave

  file {
    '/usr/lib/libjvm.so':
      ensure => link,
      target => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/libjvm.so';
  }
}
