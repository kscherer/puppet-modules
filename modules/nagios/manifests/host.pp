#Puppetize standard nagios definitions
class nagios::host(
  $nagios_dir = $nagios::params::nagios_dir
  ) inherits nagios::params {

  @@nagios_host {
    'generic-host':
      notifications_enabled        => '1',
      event_handler_enabled        => '1',
      flap_detection_enabled       => '1',
      failure_prediction_enabled   => '1',
      process_perf_data            => '1',
      retain_status_information    => '1',
      retain_nonstatus_information => '1',
      notification_period          => '24x7',
      register                     => '0';
    'linux-server':
      use                   => 'generic-host',
      check_period          => '24x7',
      check_interval        => '5',
      retry_interval        => '1',
      max_check_attempts    => '10',
      check_command         => 'check_host_alive',
      notification_interval => '120',
      notification_options  => 'd,u,r',
      contact_groups        => 'admins',
      register              => '0';
  }

  #make sure that entries no longer in storedconfigs are cleaned out
  resources {
    ['nagios_host','nagios_hostextinfo']:
      notify  => Service['nagios'],
      purge => true;
  }

  $host_cfg = "${nagios_dir}/nagios_host.cfg"
  # collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host <<||>> {
    notify  => Service['nagios'],
    before  => File[$host_cfg],
  }

  $hostext_cfg = "${nagios_dir}/nagios_hostextinfo.cfg"
  Nagios_hostextinfo <<||>> {
    notify  => Service['nagios'],
    require => File[$nagios_dir],
    before  => File[$hostext_cfg],
  }

  file {
    [ $host_cfg, $hostext_cfg ]:
      notify  => Service['nagios'],
      require => Package['nagios'],
      owner   => 'root',
      group   => 'nagios',
      mode    => '0664',
  }
}
