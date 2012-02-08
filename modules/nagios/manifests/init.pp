#
class nagios {
  package {
    ['nagios', 'nagios-plugins-all']:
      ensure => 'latest';
  }

  service {
    'nagios':
      ensure     => 'running',
      hasstatus  => true,
      hasrestart => true,
      require    => Package['nagios'],
  }

  # collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host <<||>> {
    notify => Service['nagios'],
  }
  Nagios_service <<||>> {
    notify => Service['nagios'],
  }
  Nagios_hostextinfo <<||>> {
    notify => Service['nagios'],
  }

}
