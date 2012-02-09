class nagios::target {

  @@nagios_host {
    $::fqdn:
      ensure             => present,
      alias              => $::hostname,
      address            => $::ipaddress,
      use                => 'linux-server',
  }

  @@nagios_hostextinfo {
    $::fqdn:
      ensure          => present,
      icon_image_alt  => $::operatingsystem,
      icon_image      => "base/${::operatingsystem}.png",
      statusmap_image => "base/${::operatingsystem}.gd2",
  }

  @@nagios_service {
    "check_ssh_${::hostname}":
      use                 => 'generic-service',
      check_command       => 'check-ssh',
      service_description => 'SSH Service',
      host_name           => $::fqdn,
  }

}
