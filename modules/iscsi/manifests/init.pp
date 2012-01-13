
# set the global iscsi options
define iscsi::config(
  $iscsi_initiator_name,
  $iscsi_replacement_timeout=15,
  $iscsi_noop_out_interval=5,
  $iscsi_noop_out_timeout=5
){
  if ! $iscsi_initiator_name {
    fail('You must specify $iscsi_initiator_name!')
  }

  file{
    '/etc/iscsi/initiatorname.iscsi':
      content => "InitiatorName=$iscsi_initiator_name\nInitiatorAlias=$hostname\n",
      require => Package['iscsi-initiator-utils'],
      notify  => Service[ 'iscsi' ],
      owner   => root, group => root, mode => 0644;
  }

  file{
    '/etc/iscsi/iscsid.conf':
      content => template('iscsi/iscsid.conf.erb'),
      require => Package['iscsi-initiator-utils'],
      notify  => Service[ 'iscsi' ],
      owner   => root, group => root, mode => 0600;
  }
}

# For each iface trigger a set of commands to create, assign an eth device
# discover targets and then finally log on.
define iscsi::connection($iscsi_connection_device){

  #create a new iscsi iface if it does not already exist
  #this triggers the other commands
  exec {
    "create_$name":
      command => "iscsiadm -m iface -I $name -o new",
      path    => '/usr/bin/:/sbin/:/bin',
      unless  => "iscsiadm -m iface | grep -q $name",
      notify  => Exec["update_$name"];
  }

  #bind the new iface to a specific network device
  exec {
    "update_$name":
      logoutput   => true,
      refreshonly => true,
      path        => '/usr/bin/:/sbin/:/bin',
      notify      => Exec["create_iscsi_${name}_nodes"],
      command     =>
      "iscsiadm -m iface -I $name -o update -n iface.net_ifacename \
      -v $iscsi_connection_device;true";
  }

  #each iface has two connections to two different controllers
  $iscsi_target_name = extlookup("iscsi_target_name")
  $iscsi_node_port0 = extlookup("iscsi_node_${name}_port0")
  $iscsi_node_port1 = extlookup("iscsi_node_${name}_port1")

  #create the iscsi node for each iface
  exec {
    "create_iscsi_${name}_nodes":
      path        => '/usr/bin/:/sbin/:/bin',
      refreshonly => true,
      notify      => Exec[ "login_iscsi_$name" ],
      logoutput   => true,
      command     =>
      "iscsiadm -m node -o new -I $name -p $iscsi_node_port0 -T $iscsi_target_name;\
       iscsiadm -m node -o new -I $name -p $iscsi_node_port1 -T $iscsi_target_name;\
       true";
  }

  #finally log into each iscsi connection. This create /dev/sd* devices for
  #each connection and disk on the SAN
  exec {
    "login_iscsi_$name":
      path        => '/usr/bin/:/sbin/:/bin',
      refreshonly => true,
      logoutput   => true,
      command     => "iscsiadm -m node -I $name -l";
  }
}

define iscsi::net_config ( $mtu = 1500 ) {
  network_config { "$name":
    exclusive     => 'false',
    bootproto     => 'static',
    onboot        => 'yes',
    userctl       => 'no',
    netmask       => extlookup("${name}_netmask"),
    broadcast     => extlookup("${name}_broadcast"),
    ipaddr        => extlookup("${name}_ip"),
    hwaddr        => extlookup("${name}_mac"),
    mtu           => $mtu,
    notify        => Service['network'],
    ensure        => present;
  }
}

class iscsi {

  #mandatory packages for iscsi
  package {
    [ 'iscsi-initiator-utils', 'device-mapper-multipath']:
      ensure => installed;
  }

  if $operatingsystemrelease == '6.2' {
    $lan_port = em1
    $san_port1 = p1p1
    $san_port2 = p1p3
  } else {
    $lan_port = eth0
    $san_port1 = eth2
    $san_port2 = eth5
  }

  service {
    'iscsi':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [ Iscsi::Net_config["${san_port1}"],
                      Iscsi::Net_config["${san_port2}"],
                      Package['iscsi-initiator-utils'] ];
  }

  service {
    'iscsid':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [ Iscsi::Net_config["${san_port1}"],
                      Iscsi::Net_config["${san_port2}"],
                      Package['iscsi-initiator-utils'] ];
  }

  #configure each host based on extlookup data for each host
  iscsi::net_config { "$lan_port": }
  iscsi::net_config { "${san_port1}": mtu => 9000; }
  iscsi::net_config { "${san_port2}": mtu => 9000; }

  iscsi::config {
    'iscsi_config':
      iscsi_initiator_name => extlookup('iscsi_initiator_name');
  }

  #make two iscsi connections, one for each iface
  iscsi::connection {
    'iface0':
      iscsi_connection_device => "${san_port1}",
      require                 => Service['iscsi'];
    'iface1':
      iscsi_connection_device => "${san_port2}",
      require                 => Service['iscsi'];
  }

  service {
    'multipathd':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [ Iscsi::Connection['iface0'],
                      Iscsi::Connection['iface1'],
                      Package['device-mapper-multipath']];
  }

  $wwid_disk1 = extlookup('wwid_disk1')
  $wwid_disk2 = extlookup('wwid_disk2')

  file {
    "/etc/multipath.conf":
      content  => template('iscsi/multipath.conf.erb'),
      require => Package['device-mapper-multipath'],
      notify  => [ Service[ 'multipathd' ], Exec['create_multipath'] ],
      owner   => root, group => root, mode => 0644;
  }

  # setup the multipath configuration. To be safe, first clear all
  # previous config. Only do the command if there are valid iscsi sessions
  exec {
    'create_multipath':
      command     => 'multipath -F; multipath',
      path        => '/usr/bin/:/sbin/:/bin',
      onlyif      => 'iscsiadm -m session',
      refreshonly => true,
      require     => [ Iscsi::Connection['iface0'],
                       Iscsi::Connection['iface1'],
                       File['/etc/multipath.conf']],
      notify      => Service['multipathd'];
  }

  #base directories to hold build areas
  file {
    ['/ba1','/ba2']:
      owner => root, group => root,
      ensure => directory;
  }

  #how the mount is defined
  define mpath_mount($device) {
    mount {
      "$name":
        atboot => true,
        device => "$device",
        ensure => mounted,
        fstype => ext3,
        options => 'noatime,nodiratime,data=writeback,_netdev,reservation,commit=100',
        require => [ File["$name"], Service['multipathd'] ],
        remounts => true;
      }
  }

  mpath_mount {
    '/ba1':
      device => '/dev/mapper/ba1p1';
    '/ba2':
      device => '/dev/mapper/ba2p1';
  }
}

#This is here as an easy way to disable iscsi and multipath
class iscsi::disable {
  exec {
    'iscsi_disable':
      path    => '/usr/bin/:/sbin/:/bin',
      tag     => 'disable_iscsi',
      command =>
      'multipath -F; service multipathd -F; service iscsi stop;\
      iscsiadm -m node -o delete; iscsiadm -m iface -I iface0 -o delete;\
      iscsiadm -m iface -I iface1 -o delete';
  }
}
