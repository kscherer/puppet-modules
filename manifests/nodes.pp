node default {
}

node master_common {
  class { redhat: }
  class { java: distribution => 'java-1.6.0-openjdk' }
  class { activemq: broker_name => 'ala-broker' }
  class { wr::mcollective: }
  class { wr::master: }
}

node 'ala-lpd-puppet.wrs.com' inherits master_common {
}

node 'pek-lpd-puppet.wrs.com' inherits master_common {
}

node 'yow-lpd-puppet.ottawa.wrs.com' inherits master_common {
}
