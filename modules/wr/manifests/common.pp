#
class wr::common {
  #Make sure that the machine is in the hosts file
  host {
    $::fqdn:
      ip           => $::ipaddress,
      host_aliases => $::hostname;
    'localhost':
      host_aliases => 'localhost.localdomain',
      ip           => '127.0.0.1';
  }
}
