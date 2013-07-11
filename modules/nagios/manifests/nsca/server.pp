#
class nagios::nsca::server {

  package { 'nsca': ensure => installed }

  service { 'nsca':
    ensure     => running,
    hasstatus  => false,
    hasrestart => true,
    require    => Package['nsca'],
  }

  file { '/etc/nagios/nsca.cfg':
    source => 'puppet:///modules/nagios/nsca/nsca.cfg',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0400',
    notify => Service['nsca'],
  }

}
