#System responsible for mesos master, chronus, zookeeper and private
#docker registry
class wr::ala_lpd_mesos {
  include profile::nis
  include ssmtp
  include docker
  include collectd

  docker::image {
    'registry':
      image_tag => 'latest';
  }
}
