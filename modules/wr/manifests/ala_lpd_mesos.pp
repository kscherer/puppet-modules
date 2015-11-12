#System responsible for mesos master, chronus, zookeeper and private
#docker registry
class wr::ala_lpd_mesos {
  include profile::mesos::master
  include profile::collectd

  #running zookeeper in docker means zookeeper will restart when docker restarts
  include zookeeper
}
