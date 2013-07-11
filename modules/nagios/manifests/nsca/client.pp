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

  if $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '10.04' {
    $nsca_package = 'nsca'
  } elsif $::operatingsystem == 'OpenSuse' {
    $nsca_package = 'nagios-nsca-client'
  } else {
    $nsca_package = 'nsca-client'
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
