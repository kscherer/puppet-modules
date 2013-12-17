#Install the nsca client and wrapper
class nagios::nsca::client {

  group {
    'nagios':
      ensure => present;
  }

  user {
    'nagios':
      ensure     => present,
      shell      => '/bin/sh',
      home       => '/etc/nagios',
      groups     => 'nagios',
      managehome => false;
  }

  if $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '10.04' {
    $nsca_package = 'nsca'
  } elsif $::operatingsystem == 'OpenSuse' and $::lsbmajdistrelease < '13' {
    $nsca_package = 'nagios-nsca-client'
  } else {
    $nsca_package = 'nsca-client'
  }

  package { $nsca_package: ensure => installed }
  Class['wr::common::repos'] -> Class['nagios::nsca::client']

  file {
    '/etc/nagios/send_nsca.cfg':
      source => 'puppet:///modules/nagios/nsca/send_nsca.cfg',
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
