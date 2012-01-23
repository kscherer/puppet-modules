node default {
}

node 'ala-lpd-puppet.wrs.com' {
  Class['redhat']
  -> Class['java']
  -> Class['activemq']

  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'ala-broker' }
  class { wr::mcollective: }
  class { wr::master: }

  Class['redhat']
  -> Class['nrpe']
  class { nrpe: }
}

node 'pek-lpd-puppet.wrs.com' {
  Class['redhat']
  -> Class['java']
  -> Class['activemq']

  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'pek-broker' }
  class { wr::mcollective: }
  class { wr::master: }

  Class['redhat']
  -> Class['nrpe']
  class { nrpe: }
}

node 'yow-lpd-puppet.ottawa.wrs.com' {
  class { redhat: }
  class { wr::mcollective: }
  class { wr::master: }

  Class['redhat']
  -> Class['nrpe']
  class { nrpe: }
}

node 'yow-lpg-amqp.ottawa.windriver.com' {
  Class['redhat']
  -> Class['java']
  -> Class['activemq']
  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }

  #need to define these here due to template declared here
  #will move when I fix the activemq class
  $broker_name = 'yow-broker'
  $webconsole_real = true
  class { activemq:
    broker_name => 'yow-broker',
    server_config => template('wr/yow-activemq.xml.erb')
  }
  class { wr::mcollective: }

  Class['redhat']
  -> Class['nrpe']
  class { nrpe: }
}
