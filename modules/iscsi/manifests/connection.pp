# For each iface trigger a set of commands to create, assign an eth device
# discover targets and then finally log on.
define iscsi::connection(
  $iscsi_connection_device,
  $iscsi_target_name,
  $iscsi_node_port0,
  $iscsi_node_port1 = 'UNSET'
  ){

  #create a new iscsi iface if it does not already exist
  #this triggers the other commands
  exec {
    "create_$name":
      command => "iscsiadm -m iface -I $name -o new",
      path    => '/usr/bin/:/sbin/:/bin',
      unless  => "iscsiadm -m iface | grep -q $name",
      notify  => Exec["login_iscsi_$name"],
  }

  #bind the new iface to a specific network device
  exec {
    "update_$name":
      path    => '/usr/bin/:/sbin/:/bin',
      unless  =>
        "iscsiadm -m iface | grep $name | grep -q $iscsi_connection_device",
      require => Exec["create_$name"],
      notify  => Exec["login_iscsi_$name"],
      command => "iscsiadm -m iface -I $name -o update -n iface.net_ifacename\
                  -v $iscsi_connection_device;true";
  }

  #create the iscsi node for each iface
  exec {
    "create_iscsi_${name}_node0":
      path    => '/usr/bin/:/sbin/:/bin',
      unless  => "iscsiadm -m node | grep -q ${iscsi_node_port0}",
      require => [ Exec["update_$name"], Exec["create_$name"]],
      notify  => Exec["login_iscsi_$name"],
      command => "iscsiadm -m node -o new -I $name -p $iscsi_node_port0\
                  -T $iscsi_target_name; true";
  }

  #create a second node for the iface if requested
  if $iscsi_node_port1 != 'UNSET' {
    exec {
      "create_iscsi_${name}_node1":
        path    => '/usr/bin/:/sbin/:/bin',
        unless  => "iscsiadm -m node | grep -q ${iscsi_node_port1}",
        require => [ Exec["update_$name"], Exec["create_$name"]],
        notify  => Exec["login_iscsi_$name"],
        command => "iscsiadm -m node -o new -I $name -p $iscsi_node_port1\
                    -T $iscsi_target_name; true";
    }
  }

  #finally log into each iscsi connection. This create /dev/sd* devices for
  #each connection and disk on the SAN. The check makes sure that there
  #are as many connections as nodes
  exec {
    "login_iscsi_$name":
      path    => '/usr/bin/:/sbin/:/bin',
      unless  => "test `iscsiadm -m node |grep $iscsi_target_name | \
        wc -l` -eq `iscsiadm -m session | grep $iscsi_target_name | \
        wc -l` &> /dev/null",
      command => "iscsiadm -m node -I $name -l; true";
  }
}
