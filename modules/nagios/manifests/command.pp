#Puppetize standard nagios definitions
class nagios::command(
  $nagios_dir  = $nagios::params::nagios_dir,
  $nagios_confdir = $nagios::params::nagios_confdir
  ) inherits nagios::params {

  @@nagios_command {
    'notify-host-by-email':
      command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$';
  'notify-service-by-email':
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$\n" | /bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$';
  'check_host_alive':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5';
  'check_ssh':
    command_line => '$USER1$/check_ssh $ARG1$ $HOSTADDRESS$';
  'check_snmp':
    command_line => '$USER1$/check_snmp -H $HOSTADDRESS$ $ARG1$';
  'check_http':
    command_line => '$USER1$/check_http -I $HOSTADDRESS$ $ARG1$';
  'check_mc_nrpe':
    command_line => "/usr/sbin/check-mc-nrpe --config ${nagios_confdir}/client.cfg -W $ARG1$ -T $ARG2$ $ARG3$";
  }

  $command_cfg = "${nagios_confdir}/nagios_command.cfg"
  Nagios_command <<||>> {
    target  => $command_cfg,
    notify  => Service['nagios'],
    require => File[$nagios_confdir],
    before  => File[$command_cfg],
  }

  exec {
    'mc_client_cfg_copy':
      command => "cp -f /etc/mcollective/client.cfg ${nagios_dir}/client.cfg",
      unless  => "diff /etc/mcollective/client.cfg ${nagios_dir}/client.cfg";
  }

  file {
    'check-mc-nrpe':
      path   => '/usr/sbin/check-mc-nrpe',
      source => 'puppet:///nagios/check-mc-nrpe';
    'mc-nrpe_cfg':
      path    => "${nagios_dir}/client.cfg",
      require => Exec['mc_client_cfg_copy'],
      owner   => nagios,
      group   => nagios,
      mode    => '0600';
    $command_cfg:
      notify  => Service['nagios'],
      require => Package['nagios'],
      owner   => 'root',
      group   => 'nagios',
      mode    => '0664',
  }
}
