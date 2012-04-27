#The md3000 has 4 connections total: 2 ifaces and 2 ports per
#iface.
class iscsi::md3000 inherits iscsi {

  File['/etc/iscsi/iscsid.conf']
  -> Iscsi::Net_config[$iscsi::lan_port]
  -> Iscsi::Net_config[$iscsi::san_port1]
  -> Iscsi::Net_config[$iscsi::san_port2]
  -> Iscsi::Connection['iface0']
  -> Iscsi::Connection['iface1']
  -> Service['iscsi']
  -> Service['iscsid']

  iscsi::net_config { $san_port1: mtu => 9000; }
  iscsi::net_config { $san_port2: mtu => 9000; }

  #make two iscsi connections, one for each iface
  iscsi::connection {
    'iface0':
      iscsi_connection_device => $iscsi::san_port1,
      iscsi_target_name       => extlookup('iscsi_target_name'),
      iscsi_node_port0        => extlookup('iscsi_node_iface0_port0'),
      iscsi_node_port1        => extlookup('iscsi_node_iface0_port1');
    'iface1':
      iscsi_connection_device => $iscsi::san_port2,
      iscsi_target_name       => extlookup('iscsi_target_name'),
      iscsi_node_port0        => extlookup('iscsi_node_iface1_port0'),
      iscsi_node_port1        => extlookup('iscsi_node_iface1_port1');
  }
}
