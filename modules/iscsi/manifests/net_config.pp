
define iscsi::net_config (
  $gateway = undef,
  $mtu     = 1500
  ){
  network_config {
    $name:
      ensure    => present,
      exclusive => false,
      bootproto => 'static',
      onboot    => 'yes',
      userctl   => 'no',
      netmask   => extlookup("${name}_netmask"),
      broadcast => extlookup("${name}_broadcast"),
      ipaddr    => extlookup("${name}_ip"),
      hwaddr    => extlookup("${name}_mac"),
      mtu       => $mtu,
      gateway   => $gateway,
      notify    => Service['network'];
  }
}
