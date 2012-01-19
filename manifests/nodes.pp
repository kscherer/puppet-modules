node default {
}

node 'ala-lpd-puppet.wrs.com' inherits master_common {
  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'ala-broker' }
  class { wr::mcollective: }
  class { wr::master: }
}

node 'pek-lpd-puppet.wrs.com' inherits master_common {
  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'pek-broker' }
  class { wr::mcollective: }
  class { wr::master: }
}

node 'yow-lpd-puppet.ottawa.wrs.com' inherits master_common {
  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'yow-broker' }
  class { wr::mcollective: }
  class { wr::master: }
}
