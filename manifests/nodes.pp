node default {
}

node 'ala-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers          => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'java':    distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq': broker_name => 'ala-broker' }
  -> class { 'wr::mcollective': }
  -> class { 'wr::master': }
}

node 'pek-lpd-puppet.wrs.com' {
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers          => ['ntp-1.wrs.com','ntp-2.wrs.com'] }
  -> class { 'java':    distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq': broker_name => 'ala-broker' }
  -> class { 'wr::mcollective': }
  -> class { 'wr::master': }
}

node 'yow-lpd-puppet.ottawa.wrs.com' {
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers => ['yow-lpgbld-master.ottawa.wrs.com'] }
  -> class { 'collectd::client': }
  -> class { 'wr::mcollective': }
  -> class { 'wr::master': }
}

node 'yow-lpg-amqp.ottawa.windriver.com' {
  #need to define these here due to template declared here
  #will move when I fix the activemq class
  $broker_name = 'yow-broker'
  $webconsole_real = true
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers       => ['yow-lpgbld-master.ottawa.wrs.com'] }
  -> class { 'java': distribution => 'java-1.6.0-openjdk' }
  -> class { 'activemq':
    broker_name   => 'yow-broker',
    server_config => template('wr/yow-activemq.xml.erb')
  }
  -> class { 'collectd::client': }
  -> class { 'wr::mcollective': }
}

node 'yow-blade1.wrs.com' {
  class { 'wr::yow-blades': }
}

node 'yow-lpd-monitor.ottawa.wrs.com' {
  class { 'redhat': }
  -> class { 'nrpe': }
  -> class { 'ntp': servers => ['yow-lpgbld-master.ottawa.wrs.com'] }
  -> class { 'collectd::client': }
  -> class { 'wr::mcollective': }
}
