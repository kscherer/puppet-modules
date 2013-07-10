#Install the nsca client and wrapper
class nagios::nsca::client {

  package { 'nsca-client': ensure => installed }

  file {
    '/etc/nagios/send_nsca.cfg':
      source => 'puppet:///modules/nagios/nsca/nsca.cfg',
      owner  => 'nagios',
      group  => 'nogroup',
      mode   => '0400';
    '/etc/nagios/nsca_wrapper':
      source => 'puppet:///modules/nagios/nsca/nsca_wrapper',
      owner  => 'nagios',
      group  => 'nogroup',
      mode   => '0755',
  }
}
