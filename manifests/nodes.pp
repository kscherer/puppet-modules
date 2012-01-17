node default {
}

node 'ala-lpd-puppet.wrs.com' {

  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'ala-broker' }
  class { wr::mcollective: }
  class { wr::master: }
}

node 'pek-lpd-puppet.wrs.com' {

  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'pek-broker' }
  class { wr::mcollective: }
  class { wr::master: }
}
