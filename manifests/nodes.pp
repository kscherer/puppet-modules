node default {
}

node 'ala-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'ntp': servers          => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'java':    distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq': broker_name => 'ala-broker' }
  -> class { 'wr::master': }
  -> class { 'nrpe': }
  -> class { 'git::stomp_listener': }
}

node 'pek-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'ntp': servers          => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'java':    distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq': broker_name => 'pek-broker' }
  -> class { 'wr::master': }
  -> class { 'nrpe': }
  -> class { 'git::stomp_listener': }
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
  class { 'wr::xenserver': }
}

node /pek-hostel-deb0[1-6]\.wrs\.com/ {
  class { 'wr::pek-xenserver': }
}

node 'yow-lpd-monitor.wrs.com' {
  class { 'redhat': }
  -> class { 'puppet':
    puppet_server               => 'yow-lpd-puppet.wrs.com',
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'collectd::client': }
  -> class { 'wr::mcollective': client => true }
  -> class { 'ntp':
    servers => $wr::common::ntp_servers
  }
  -> class { 'wr::puppetcommander': }
  -> class { 'nrpe': }
  -> class { 'nagios': }
  -> class { 'nis': }

  class { 'nagios::target': }

  #nagios class notifies httpd service so -> relationship creates cycles
  class { 'apache': }

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

node /ala-blade2[5-9]\.wrs\.com/ {
  class { 'wr::ala-blades': }
  -> class { 'nx': }
}

node /ala-blade3[0-2]\.wrs\.com/ {
  class { 'wr::ala-blades': }
  -> class { 'nx': }
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

node /ala-lp.*\.wrs\.com/ {
  class { 'wr::ala-common': }
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

node 'ala-git-new.wrs.com' {
  class {'wr::ala-common': }
}
