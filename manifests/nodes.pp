node default {
}

node 'ala-lpd-puppet.wrs.com' {
  include wr::ala_lpd_puppet
}

node 'pek-lpd-puppet.wrs.com' {
  include wr::pek_lpd_puppet
}

node 'yow-lpd-puppet2.wrs.com' {
  include wr::yow_lpd_puppet2
}

node 'yow-lpg-amqp.wrs.com' {
  class { 'wr::yow_amqp': }
}

node /yow-blade.*.wrs.com/ {
  include profile::mesos::slave
}

node 'ala-blade17.wrs.com' {
  include zookeeper
  include profile::mesos::master
  include profile::lava
}

node /ala-blade([1-9]|19|31|3[3-9]|4[0-5]|49|5[0-9]|6[0-9])\.wrs\.com/ {
  include profile::mesos::slave
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

node /pek-blade3[0-9]\.wrs\.com/ {
  include profile::mesos::slave
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

node 'ala-lpggp5.wrs.com' {
  include profile::gp_builder
}

node /ala-lpggp\d+\.wrs\.com/ {
  class { 'wr::ala_lpggp': }
}

node 'yow-lpggp3.wrs.com' {
  include profile::gp_builder
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
  include profile::collectd
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

node 'ala-lpd-susbld.wrs.com' {
  class { 'wr::ala_lpd_susbld': }
}

node 'ala-lpd-susbld2.wrs.com' {
  include wr::ala_lpd_susbld
  include yocto
}

node 'yow-lpd-provision.wrs.com' {
  include ::wr::yow_lpd_provision
}

node 'ala-lpd-provision.wrs.com' {
  include ::wr::ala_lpd_provision
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

node 'yow-lpd-stats.wrs.com' {
  include wr::yow_lpd_stats
}

node /yow-osc\d+-lx\.wrs\.com/ {
  include wr::yow_osc
}

node /yow-ddtest\d+-lx\.wrs\.com/ {
  include wr::yow_osc
}

node 'yow-pelement-d2.wrs.com' {
  include wr::yow_osc
}

node 'hp-proliant-dl380p-2.wrs.com' {
  class { 'ovirt::selfhosted': }
}

node 'yow-srt-lx1.wrs.com' {
  class { 'ovirt::selfhosted': }
}
node 'yow-srt-lx2.wrs.com' {
  class { 'ovirt::selfhosted': }
}
node 'yow-srt-lx3.wrs.com' {
  class { 'ovirt::selfhosted': }
}

node 'yow-jenkins-vm1.wrs.com' {
  include jenkins
}

node 'yow-jenkins-vm2.wrs.com' {
  include jenkins
}

node 'yow-tla2-lx.wrs.com' {
    include wr::yow_eng_vm
}

node 'yow-ovp4.wrs.com' {
    include wr::yow_ovp_ub
}

node 'yow-jkeffer-lx.wrs.com' {
    include wr::yow_eng_vm
}

node 'yow-ovp5.wrs.com' {
  include wr::yow_ovp_rhel
}

node 'yow-ovp6.wrs.com' {
  include profile::mesos::slave
}

node 'yow-lpdfs01.wrs.com' {
    include wr::fileserver
}

node 'ala-lpdfs01.wrs.com' {
    include wr::fileserver
}

node 'pek-lpdfs01.wrs.com' {
  include wr::fileserver
}

node /pek-lpggp\d+\.wrs\.com/ {
  include profile::gp_builder
}

node 'otp-linux01.corp.ad.wrs.com' {
  include profile::gp_builder
}

node 'otp-rhfs1-new.wrs.com' {
  include wr::fileserver
}
