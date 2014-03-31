#
class profile::mesos::master inherits profile::mesos::common {
  include mesos::master
  include docker
  File['/usr/lib/libjvm.so'] -> Package['mesos']
  Apt::Source['mesos'] -> Package['mesos']
}
