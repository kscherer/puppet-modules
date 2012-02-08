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

  file {
    [ '/etc/nagios/nagios_host.cfg','/etc/nagios/nagios_hostextinfo.cfg',
      '/etc/nagios/nagios_service.cfg']:
        mode => '0644',
  }
}
