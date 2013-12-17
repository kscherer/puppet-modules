class nagios::target {

  case $::hostname {
    /yow-lpgbld-vm/: { $hostgroup='hostel'}
    /yow-lppgp/: { $hostgroup='yow-lpggp'}
    /yow-blade/: { $hostgroup='yow-blades'}
    /ala-blade/: { $hostgroup='ala-blades'}
    default: {}
  }

  @@nagios_host {
    $::fqdn:
      ensure     => present,
      alias      => $::hostname,
      address    => $::ipaddress_eth0,
      hostgroups => $hostgroup,
      use        => 'linux-server',
  }

  $os = downcase($::operatingsystem)

  @@nagios_hostextinfo {
    $::fqdn:
      ensure          => present,
      icon_image_alt  => $::operatingsystem,
      icon_image      => "${os}.png",
      statusmap_image => "${os}.gd2",
  }

  @@nagios_service {
    "check_ssh_${::hostname}":
      use                 => 'generic-service',
      check_command       => 'check_ssh',
      service_description => 'SSH',
      host_name           => $::fqdn,
  }

  include nagios::nsca::client
  @@nagios_service {
    "check_ntp_${::hostname}":
      use                 => 'passive-service',
      service_description => 'Passive NTP',
      host_name           => $::fqdn,
      servicegroups       => 'ntp',
  }

  $nsca_server=hiera('nsca')

  cron {
    'nsca_ntp_check':
      command => "PATH=/bin:/sbin:/usr/sbin:/usr/bin /etc/nagios/nsca_wrapper -H ${::fqdn} -S 'Passive NTP' -N ${nsca_server} -c /etc/nagios/send_nsca.cfg -C /etc/nagios/check_ntp.sh -q",
      user    => 'nagios',
      minute  => '*/5';
  }
}
