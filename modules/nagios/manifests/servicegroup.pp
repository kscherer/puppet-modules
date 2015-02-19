#Puppetize standard nagios definitions
class nagios::servicegroup(
  $nagios_dir = $nagios::params::nagios_dir
  ) inherits nagios::params {

  @@nagios_servicegroup {
    'ntp':
      servicegroup_name => 'ntp',
      alias             => 'NTP Passive';
    'dell-servers':
      servicegroup_name => 'dell-servers',
      alias             => 'Dell Servers';
    'git-mirrors':
      servicegroup_name => 'git-mirrors',
      alias             => 'Grokmirror mirrors';
    'mesos-slaves':
      servicegroup_name => 'mesos-slaves',
      alias             => 'Mesos Slaves';
  }

  #make sure that entries no longer in storedconfigs are cleaned out
  resources {
    'nagios_servicegroup':
      notify => Service['nagios'],
      purge  => true;
  }

  $servicegroup_cfg = "${nagios_dir}/nagios_servicegroup.cfg"
  Nagios_servicegroup <<||>> {
    notify  => Service['nagios'],
    require => File[$nagios_dir],
    before  => File[$servicegroup_cfg],
  }

  file {
    $servicegroup_cfg:
      notify  => Service['nagios'],
      require => Package['nagios'],
      owner   => 'root',
      group   => 'nagios',
      mode    => '0664',
  }
}
