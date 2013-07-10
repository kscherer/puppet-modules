class nagios::nsca::client {

  package { 'nsca-client': ensure => installed }

  file {
    '/etc/send_nsca.cfg':
      source => 'puppet:///modules/nagios/nsca/nsca.cfg',
      owner  => 'nagios',
      group  => 'nogroup',
      mode   => '0400',
  }
}
