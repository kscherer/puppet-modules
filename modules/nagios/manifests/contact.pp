#Puppetize standard nagios definitions
class nagios::contact(
  $nagios_confdir = $nagios::params::nagios_confdir
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

  $contact_cfg = "${nagios_confdir}/nagios_contact.cfg"
  Nagios_contact <<||>> {
    target  => $contact_cfg,
    notify  => Service['nagios'],
    require => File[$nagios_confdir],
    before  => File[$contact_cfg],
  }

  $contactgroup_cfg = "${nagios_confdir}/nagios_contactgroup.cfg"
  Nagios_contactgroup <<||>> {
    target  => $contactgroup_cfg,
    notify  => Service['nagios'],
    require => File[$nagios_confdir],
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
