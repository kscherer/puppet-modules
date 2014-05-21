#System responsible for mesos master, chronus, zookeeper and private
#docker registry
class wr::ala_lpd_mesos {
  include profile::mesos::master
  include profile::mesos::chronos
  include profile::docker::registry
  include ssmtp
  include collectd

  #running zookeeper in docker means zookeeper will restart when docker restarts
  include zookeeper
}
