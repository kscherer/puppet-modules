node default {
}

node 'ala-lpd-puppet.wrs.com' {
  class { 'wr::ala-lpd-puppet': }
}

node 'pek-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'ntp': servers          => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'wr::activemq': broker_name => 'pek-broker' }
  -> class { 'wr::master': }
  -> class { 'nrpe': }
  -> class { 'git::stomp_listener': }
  -> class { 'wr::puppetcommander': }
}

node 'yow-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'ntp': servers => ['yow-lpggp1.wrs.com'] }
  -> class { 'collectd::client': }
  -> class { 'wr::master': }
  -> class { 'nrpe': }
  -> class { 'nagios::target': }
  -> class { 'git::stomp_listener': }
}

node 'yow-lpg-amqp.wrs.com' {
  class { 'wr::yow-amqp': }
}

node /yow-blade.*.wrs.com/ {
  class { 'wr::yow-blades': }
}

#test buildbot cluster
node /yow-lpgbld-[0-2][0-9]\.wrs\.com/ {
  class { 'wr::yow-buildbot-slave': }
}

node /yow-lpgbld-[3-5][0-9]\.wrs\.com/ {
  class { 'wr::xenserver': }
}

node 'yow-lpgbld-master.wrs.com' {
  class { 'wr::xenserver': client => true }
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

node /pek-hostel-vm\d+\.wrs\.com$/ {
  class { 'wr::pek-hostel': }
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
  class {'wr::yow-common': }
}

node 'ala-lpd-susbld.wrs.com' {
  class { 'wr::ala-lpd-susbld': }
}

node /ala-lp.*\.wrs\.com/ {
  class { 'wr::ala-common': }
}
