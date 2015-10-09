#
class wr::common::etc_host_setup {
  if 'em1' in $::interfaces {
    $public_ip=$::ipaddress_em1
  } else {
    $public_ip=$::ipaddress_eth0
  }
  #Make sure that the machine is in the hosts file
  if $::domain == 'wrs.com' {
    host {
      $::fqdn:
        ip           => $public_ip,
        host_aliases => $::hostname;
    }
  } else {
    host {
      "${::hostname}.wrs.com":
        ip           => $public_ip,
        host_aliases => $::hostname;
    }
  }
  host {
    'localhost':
      host_aliases => 'localhost.localdomain',
      ip           => '127.0.0.1';
    # Use hosts file as substitute for geographically aware DNS
    # Default to ala-lpdfs01
    'wr-docker-registry':
      ensure       => present,
      ip           => hiera('wr::docker_registry_ip', '147.11.105.120'),
      host_aliases => 'wr-docker-registry.wrs.com';
  }
}
