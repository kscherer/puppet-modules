
#netapp has only one connection to host
class iscsi::netapp inherits iscsi {

  File['/etc/iscsi/iscsid.conf']
  -> Iscsi::Net_config[$iscsi::lan_port]
  -> Iscsi::Net_config[$iscsi::san_port1]
  -> Iscsi::Connection['iface0']
  -> Service['iscsi']
  -> Service['iscsid']

  iscsi::net_config { $iscsi::san_port1: mtu => 9000; }

  iscsi::connection {
    'iface0':
      iscsi_connection_device => $iscsi::san_port1,
      iscsi_target_name       => extlookup('iscsi_target_name'),
      iscsi_node_port0        => extlookup('iscsi_node_iface0_port0');
  }
}
