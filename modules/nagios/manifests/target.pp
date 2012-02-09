class nagios::target {

  @@nagios_host {
    $::fqdn:
      ensure             => present,
      alias              => $::hostname,
      address            => $::ipaddress,
      use                => 'linux-server',
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

}
