#Puppetize standard nagios definitions
class nagios::timeperiod(
  $nagios_dir = $nagios::params::nagios_dir
  ) inherits nagios::params {

  @@nagios_timeperiod {
    '24x7':
      alias     => '24 Hours A Day, 7 Days A Week',
      sunday    => '00:00-24:00',
      monday    => '00:00-24:00',
      tuesday   => '00:00-24:00',
      wednesday => '00:00-24:00',
      thursday  => '00:00-24:00',
      friday    => '00:00-24:00',
      saturday  => '00:00-24:00';
    'workhours':
      alias     => 'Normal Work Hours',
      monday    => '08:00-17:00',
      tuesday   => '08:00-17:00',
      wednesday => '08:00-17:00',
      thursday  => '08:00-17:00',
      friday    => '08:00-17:00';
  }
  #make sure that entries no longer in storedconfigs are cleaned out
  resources {
    'nagios_timeperiod':
      purge => true;
  }

  $timeperiod_cfg = "${nagios_dir}/nagios_timeperiod.cfg"
  Nagios_timeperiod <<||>> {
    notify  => Service['nagios'],
    require => File[$nagios_dir],
    before  => File[$timeperiod_cfg],
  }

  file {
    $timeperiod_cfg:
      notify  => Service['nagios'],
      require => Package['nagios'],
      owner   => 'root',
      group   => 'nagios',
      mode    => '0664',
  }
}
