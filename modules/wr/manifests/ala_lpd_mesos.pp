#System responsible for mesos master, chronus, zookeeper and private
#docker registry
class wr::ala_lpd_mesos {
  include profile::mesos::master
  include profile::collectd

  #running zookeeper in docker means zookeeper will restart when docker restarts
  include zookeeper

  include ::profile::docker

  docker::run {
    'wraxl_scheduler':
      image           => 'wr-docker-registry:5000/mesos-scheduler:0.25.0',
      command         => '--master zk://147.11.106.56:2181,147.11.105.21:2181,147.11.105.120:2181/mesos --config /mnt/random_coverage_config.yaml &> /var/log/upstart/wraxl_scheduler.log',
      ports           => ['8080:8080'],
      net             => 'host',
      restart_service => true,
      pull_on_start   => true,
      volumes         => ['/home/wrlbuild/wr-buildscripts:/mnt/',
                          '/var/log:/var/log/'],
      require         => [Service['docker']];
  }
}
