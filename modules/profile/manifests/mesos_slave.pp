#
class profile::mesos_slave inherits profile::nis {
  include mesos::slave
}
