class wr::ala_lpd_mesos {
  include profile::nis
  include ssmtp
  include docker
  include collectd
}
