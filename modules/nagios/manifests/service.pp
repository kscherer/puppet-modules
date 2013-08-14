#Puppetize standard nagios definitions
class nagios::service(
  $nagios_dir = $nagios::params::nagios_dir
  ) inherits nagios::params {

  @@nagios_service {
    'generic-service':
      active_checks_enabled        => '1',
      passive_checks_enabled       => '0',
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
      max_check_attempts           => '1',
      normal_check_interval        => '10',
      retry_check_interval         => '2',
      contact_groups               => 'admins',
      notification_options         => 'w,u,c,r',
      notification_interval        => '60',
      notification_period          => '24x7',
      register                     => '0';
    'passive-service':
      use                          => 'generic-service',
      active_checks_enabled        => '0',
      passive_checks_enabled       => '1',
      flap_detection_enabled       => '0',
      is_volatile                  => '0',
      check_command                => 'check_dummy!0',
      notification_options         => 'w,u,c,r',
      notification_interval        => '60',
      notification_period          => '24x7',
      stalking_options             => 'w,c,u',
      register                     => '0';
    'puppet':
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => 'mc_puppet_run',
      check_command       => 'check_mc_nrpe!puppet!check_puppet';
    'puppet_failures':
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => 'mc_puppet_failures_run',
      check_command       => 'check_mc_nrpe!puppet!check_puppet_failures';
    'clock_check':
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => 'mc_ntp_run',
      check_command       => 'check_mc_nrpe!ntp!check_ntp';
    'disk_check':
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => 'mc_disk_check_run',
      check_command       => 'check_mc_nrpe!settings!check_disks';
    'nx_check':
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => 'mc_nx_blades_run',
      check_command       => 'check_mc_nrpe!nx!check_nx_instance';
    'check_mcollective':
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => 'check_mcollective_registration',
      check_command       => 'check_mcollective';
  }

  #make sure that entries no longer in storedconfigs are cleaned out
  resources {
    'nagios_service':
      notify  => Service['nagios'],
      purge => true;
  }

  $service_cfg = "${nagios_dir}/nagios_service.cfg"
  Nagios_service <<||>> {
    notify  => Service['nagios'],
    require => File[$nagios_dir],
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
