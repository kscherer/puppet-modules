class wr::ala_lpd_mesos {
  include profile::nis

  #setup mail
  include ssmtp

  include docker
}
