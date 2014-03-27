#
class profile::mesos_slave inherits profile::monitored {
  include mesos::slave
}
