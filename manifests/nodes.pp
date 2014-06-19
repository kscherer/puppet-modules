node default {
}

node 'ala-lpd-puppet.wrs.com' {
  include wr::ala_lpd_puppet
}

node 'pek-lpd-puppet.wrs.com' {
  include wr::common::ssh_root_keys
  class { 'redhat': }
  -> class { 'ntp': }
  -> class { 'wr::activemq': broker_name => 'pek-broker' }
  -> class { 'wr::master': }
  -> class { 'nrpe': }
  -> class { 'git::stomp_listener': }
}

node 'yow-lpd-puppet2.wrs.com' {
  include wr::yow_lpd_puppet2
}

node 'yow-lpg-amqp.wrs.com' {
  class { 'wr::yow_amqp': }
}

node /yow-blade[1-3].wrs.com/ {
  include profile::mesos::slave
}

node /yow-blade.*.wrs.com/ {
  include profile::nxbuilder
  include collectd
}

node 'yow-lpgbld-24.wrs.com' {
  include profile::nis
  include yocto
}

#test buildbot cluster
node /yow-lpgbld-[0-2][0-9]\.wrs\.com/ {
  class { 'wr::yow_buildbot_slave': }
}

node /yow-lpgbld-[3-5][0-9]\.wrs\.com/ {
  include wr::xenserver
}

node 'yow-lpgbld-master.wrs.com' {
  include wr::xenserver
}

node /pek-hostel-deb0[1-6]\.wrs\.com/ {
  class { 'wr::pek_xenserver': }
}

node /pek-blade(2|3|4|5|7|8)\.wrs\.com/ {
  class { 'wr::pek_blades': }
  -> class { 'nx': }
}

node /pek-blade(17|18|19|20)\.wrs\.com/ {
  class { 'wr::pek_blades': }
  -> class { 'nx': }
}

node /pek-usp-\d+\.wrs\.com/ {
  class { 'wr::pek_usp': }
  -> class { 'nx': }
}

node 'yow-lpd-monitor.wrs.com' {
  include wr::yow_lpd_monitor
}

node /yow-lpgbld-vm\d+\.wrs\.com$/ {
  class { 'wr::yow_hostel': }
}

node /yow-lpgbuild-\d+\.wrs\.com$/ {
  class { 'wr::yow_lpgbuild': }
}

node /pek-hostel-vm(19|2[0-9]|3[0-6])\.wrs\.com$/ {
  class { 'wr::pek_hostel': }
}

node /pek-hostel-vm(0[1-9]|1[0-3])\.wrs\.com/ {
  class { 'wr::pek_hostel': }
  -> class { 'nis': }
}

node /ala-blade\d+\.wrs\.com/ {
  if $::operatingsystem == 'Ubuntu' {
    include role::nxbuilder
  } else {
    #Keep old config for CentOS builders
    include wr::ala_blades
  }
}

node /ala-lpggp\d+\.wrs\.com/ {
  class { 'wr::ala_lpggp': }
}

node /yow-lpggp\d+\.wrs\.com/ {
  class { 'wr::yow_lpggp': }
}

node /ala-lpd-test[1-3]\.wrs\.com/ {
  class { 'wr::ala_lpd_test': }
}

node 'ala-lpd-rcpl.wrs.com' {
  class {'wr::ala_lpd_rcpl': }
}

node 'ala-irc.wrs.com' {
  class { 'wr::ala_common': }
}

node 'yow-irc.wrs.com' {
  class { 'wr::irc': }
}

node 'yow-git.wrs.com' {
  include role::git::mirror
}

node 'pek-git.wrs.com' {
  include role::git::mirror
}

node 'ala-git.wrs.com' {
  include role::git::master
}

node 'msp-shared1.wrs.com' {
  include puppet
  include git
  include git::wr_bin_repo
  include git::grokmirror::mirror
}

node 'splat.wrs.com' {
  include puppet
  include git
  include git::service
  include git::wr_bin_repo
  include git::grokmirror::mirror
}

node 'ala-lpd-susbld.wrs.com' {
  class { 'wr::ala_lpd_susbld': }
}

node /(yow|ala)-lpd-provision.wrs.com/ {
  include role::provisioner
  include ssmtp
  include profile::logstash
}

node 'svl-tuxlab.wrs.com' {
  class { 'wr::svl_tuxlab': }
}

node 'ala-lpgweb2.wrs.com' {
  class { 'wr::ala_lpgweb': }
}

node /ala-lp.*\.wrs\.com/ {
  class { 'wr::ala_common': }
}

node /yow-cgts\d+-lx\.wrs\.com/ {
  include wr::cgts
}

node 'ala-lpd-mesos.wrs.com' {
  include wr::ala_lpd_mesos
}

node /yow-osc\d+-lx\.wrs\.com/ {
  include wr::yow_osc
}

node 'yow-pelement-d2.wrs.com' {
  include wr::yow_osc
}

