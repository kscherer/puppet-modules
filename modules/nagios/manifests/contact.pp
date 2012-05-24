#Puppetize standard nagios definitions
class nagios::contact(
  $nagios_dir = $nagios::params::nagios_dir
  ) inherits nagios::params {

  @@nagios_contact {
    'generic-contact':
      service_notification_period   => '24x7',
      host_notification_period      => '24x7',
      service_notification_options  => 'w,u,c,r,f,s',
      host_notification_options     => 'd,u,r,f,s',
      service_notification_commands => 'notify-service-by-email',
      host_notification_commands    => 'notify-host-by-email',
      register                      => '0';
    'nagiosadmin':
      use   => 'generic-contact',
      alias => 'Nagios Admin',
      email => 'konrad.scherer@windriver.com';
  }

  @@nagios_contactgroup {
    'admins':
      alias   => 'Nagios Administrators',
      members => 'nagiosadmin';
  }

  #make sure that entries no longer in storedconfigs are cleaned out
  resources {
    ['nagios_contact','nagios_contactgroup']:
      purge => true;
  }

  $contact_cfg = "${nagios_dir}/nagios_contact.cfg"
  Nagios_contact <<||>> {
    notify  => Service['nagios'],
    require => File[$nagios_dir],
    before  => File[$contact_cfg],
  }

  $contactgroup_cfg = "${nagios_dir}/nagios_contactgroup.cfg"
  Nagios_contactgroup <<||>> {
    notify  => Service['nagios'],
    require => File[$nagios_dir],
    before  => File[$contactgroup_cfg],
  }

  file {
    [$contact_cfg, $contactgroup_cfg]:
      notify  => Service['nagios'],
      require => Package['nagios'],
      owner   => 'root',
      group   => 'nagios',
      mode    => '0664',
  }
}
