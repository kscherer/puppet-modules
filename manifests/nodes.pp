node default {
}

node 'ala-lpd-puppet.wrs.com' {
  class { 'wr::ala-lpd-puppet': }
}

node 'pek-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'ntp': }
  -> class { 'wr::activemq': broker_name => 'pek-broker' }
  -> class { 'wr::master': }
  -> class { 'nrpe': }
  -> class { 'git::stomp_listener': }
}

node 'yow-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'ntp': }
  -> class { 'wr::master': }
  -> class { 'nrpe': }
  -> class { 'nagios::target': }
  -> class { 'git::stomp_listener': }
}

node 'yow-lpg-amqp.wrs.com' {
  class { 'wr::yow-amqp': }
}

node /yow-blade[1-3].wrs.com/ {
  class { 'wr::yow_openstack': }
}

node /yow-blade.*.wrs.com/ {
  include profile::nxbuilder
  include collectd
}

#test buildbot cluster
node /yow-lpgbld-[0-2][0-9]\.wrs\.com/ {
  class { 'wr::yow-buildbot-slave': }
}

node /yow-lpgbld-[3-5][0-9]\.wrs\.com/ {
  include wr::xenserver
}

node 'yow-lpgbld-master.wrs.com' {
  include wr::xenserver
}

node /pek-hostel-deb0[1-6]\.wrs\.com/ {
  class { 'wr::pek-xenserver': }
}

node /pek-blade(2|3|4|5|7|8|22)\.wrs\.com/ {
  class { 'wr::pek-blades': }
  -> class { 'nx': }
}

node /pek-blade(17|18|19|20|21)\.wrs\.com/ {
  class { 'wr::pek-blades': }
  -> class { 'xylo': }
  -> class { 'nx': }
}

node /pek-usp-\d+\.wrs\.com/ {
  class { 'wr::pek-usp': }
  -> class { 'nx': }
}

node 'yow-lpd-monitor.wrs.com' {
  include wr::yow_lpd_monitor
}

node /yow-lpgbld-vm\d+\.wrs\.com$/ {
  class { 'wr::yow-hostel': }
}

node /yow-lpgbuild-\d+\.wrs\.com$/ {
  class { 'wr::yow-lpgbuild': }
}

node /pek-hostel-vm(19|2[0-9]|3[0-6])\.wrs\.com$/ {
  class { 'wr::pek-hostel': }
}

node /pek-hostel-vm(0[1-9]|1[0-3])\.wrs\.com/ {
  class { 'wr::pek-hostel': }
  -> class { 'nis': }
}

node /ala-blade3[3-9]\.wrs\.com/ {
  include role::nxbuilder
}

node /ala-blade\d+\.wrs\.com/ {
  class { 'wr::ala-blades': }
}

node /ala-lpggp\d+\.wrs\.com/ {
  class { 'wr::ala-lpggp': }
}

node /yow-lpggp\d+\.wrs\.com/ {
  class { 'wr::yow-lpggp': }
}

node /ala-lpd-test[1-3]\.wrs\.com/ {
  class { 'wr::ala-lpd-test': }
}

node 'ala-lpd-rcpl.wrs.com' {
  class {'wr::ala-lpd-rcpl': }
}

node 'ala-irc.wrs.com' {
  class { 'wr::ala-common': }
}

node 'yow-irc.wrs.com' {
  class { 'wr::irc': }
}

node 'yow-lpg-md3000.wrs.com' {
  class {'wr::yow-common': }
  -> class {'nomachine': }
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

node 'ala-lpd-susbld.wrs.com' {
  class { 'wr::ala-lpd-susbld': }
}

node 'ala-lpd-provision.wrs.com' {
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

node /ala-lpgweb.*\.wrs\.com/ {
  include profile::nis
}

node /ala-lp.*\.wrs\.com/ {
  class { 'wr::ala-common': }
}

node /yow-cgts\d+-lx\.wrs\.com/ {
  include wr::cgts
}
