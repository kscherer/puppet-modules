#Install the nsca client and wrapper
class nagios::nsca::client {

  group {
    'nagios':
      ensure => present;
  }

  user {
    'nagios':
      ensure     => present,
      shell      => '/bin/false',
      groups     => 'nagios',
      managehome => false;
  }

  case $::operatingsystem {
    'OpenSuse': { $nsca_package = 'nagios-nsca-client' }
    default: { $nsca_package = 'nsca-client' }
  }

  package { $nsca_package: ensure => installed }

  file {
    '/etc/nagios/send_nsca.cfg':
      source => 'puppet:///modules/nagios/nsca/nsca.cfg',
      owner  => 'nagios',
      group  => 'nagios',
      mode   => '0400';
    '/etc/nagios/nsca_wrapper':
      source => 'puppet:///modules/nagios/nsca/nsca_wrapper',
      owner  => 'nagios',
      group  => 'nagios',
      mode   => '0755',
  }
}
