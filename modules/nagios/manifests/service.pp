#Puppetize standard nagios definitions
class nagios::service(
  $nagios_confdir = $nagios::params::nagios_confdir
  ) inherits nagios::params {

  @@nagios_service {
    'generic-service':
      active_checks_enabled        => '1',
      passive_checks_enabled       => '1',
      parallelize_check            => '1',
      obsess_over_service          => '1',
      check_freshness              => '0',
      notifications_enabled        => '1',
      event_handler_enabled        => '1',
      flap_detection_enabled       => '1',
      failure_prediction_enabled   => '1',
      process_perf_data            => '1',
      retain_status_information    => '1',
      retain_nonstatus_information => '1',
      is_volatile                  => '0',
      check_period                 => '24x7',
      max_check_attempts           => '3',
      normal_check_interval        => '10',
      retry_check_interval         => '2',
      contact_groups               => 'admins',
      notification_options         => 'w,u,c,r',
      notification_interval        => '60',
      notification_period          => '24x7',
      register                     => '0';
    'puppet':
      use                 => 'generic-service',
      host_name           => 'yow-lpd-monitor.wrs.com',
      service_description => 'mc_puppet_run',
      check_command       => 'check_mc_nrpe!puppet!yow!check_puppet',
      notification_period => 'workhours',
      contact_groups      => 'admins';
    'clock_check':
      use                 => 'generic-service',
      host_name           => 'yow-lpd-monitor.wrs.com',
      service_description => 'mc_ntp_run',
      check_command       => 'check_mc_nrpe!ntp!yow!check_ntp',
      notification_period => 'workhours',
      contact_groups      => 'admins';
    'yow-blades_nx_check':
      use                 => 'generic-service',
      host_name           => 'yow-lpd-monitor.wrs.com',
      service_description => 'mc_nx_blades_run',
      check_command       => 'check_mc_nrpe!nx::yow-blades!yow!check_nx_instance',
      notification_period => 'workhours',
      contact_groups      => 'admins';
    'yow-lpgbuild_nx_check':
      use                 => 'generic-service',
      host_name           => 'yow-lpd-monitor.wrs.com',
      service_description => 'mc_nx_lpgbuild_run',
      check_command       => 'check_mc_nrpe!nx::yow-lpgbuild!yow!check_nx_instance',
      notification_period => 'workhours',
      contact_groups      => 'admins';
    'yow_puppet_check':
      use                 => 'generic-service',
      host_name           => 'yow-lpd-monitor.wrs.com',
      service_description => 'yow_puppet_check',
      #this command uses SSL to connect to puppet, but returns "Bad Request"
      #which is all that we need to confirm service is actually running
      check_command       => 'check_http!-I 128.224.194.14 -S -p 8140 -e HTTP',
      notification_period => 'workhours',
      contact_groups      => 'admins';
  }

  #make sure that entries no longer in storedconfigs are cleaned out
  resources {
    'nagios_service':
      purge => true;
  }

  $service_cfg = "${nagios_confdir}/nagios_service.cfg"
  Nagios_service <<||>> {
    target  => $service_cfg,
    notify  => Service['nagios'],
    require => File[$nagios_confdir],
    before  => File[$service_cfg],
  }

  file {
    $service_cfg:
      notify  => Service['nagios'],
      require => Package['nagios'],
      owner   => 'root',
      group   => 'nagios',
      mode    => '0664',
  }
}
