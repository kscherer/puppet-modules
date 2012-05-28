node default {
}

node 'ala-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers          => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'java':    distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq': broker_name => 'ala-broker' }
  -> class { 'wr::master': }
}

node 'pek-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers          => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'java':    distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq': broker_name => 'pek-broker' }
  -> class { 'wr::master': }
}

node 'yow-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers => ['yow-lpgbld-master.wrs.com'] }
  -> class { 'collectd::client': }
  -> class { 'wr::master': }
  -> class { 'nagios::target': }
}

node 'yow-lpg-amqp.wrs.com' {
  #need to define these here due to template declared here
  #will move when I fix the activemq class
  $broker_name = 'yow-broker'
  $webconsole_real = true
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers       => ['yow-lpgbld-master.wrs.com'] }
  -> class { 'puppet':
    puppet_server               => 'yow-lpd-puppet.wrs.com',
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'java': distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq':
    broker_name   => 'yow-broker',
    server_config => template('wr/yow-activemq.xml.erb')
  }
  -> class { 'collectd::client': }
  -> class { 'wr::mcollective': }
  -> class { 'nagios::target': }
}

node /yow-blade.*.wrs.com/ {
  class { 'wr::yow-blades': }
}

node 'yow-lpgbld-09.wrs.com' {
  class { 'wr::yow-buildbot-slave': }
}
node /yow-lpgbld-1[0-4].wrs.com/ {
  class { 'wr::yow-buildbot-slave': }
}

node /yow-lpgbld-[1-5][0-9].*/ {
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
  -> class { 'nrpe': }
  -> class { 'ntp': servers => ['yow-lpgbld-master.wrs.com'] }
  -> class { 'puppet':
    puppet_server               => 'yow-lpd-puppet.wrs.com',
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'collectd::client': }
  -> class { 'wr::mcollective': client => true }
  -> class { 'wr::puppetcommander': }
  -> class { 'nagios': }

  class { 'nagios::target': }

  #nagios class notifies httpd service so -> relationship creates cycles
  class { 'apache': }

}

#test nodes for buildbot slaves
node /yow-lpgbld-vm1[0-9].wrs.com/ {
  class { 'wr::yow-buildbot-slave': }
}
node /yow-lpgbld-vm2[0-9].wrs.com/ {
  class { 'wr::yow-buildbot-slave': }
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
