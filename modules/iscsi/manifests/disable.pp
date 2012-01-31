#This is here as an easy way to disable iscsi and multipath
class iscsi::disable {
  exec {
    'iscsi_disable':
      tag     => 'disable_iscsi',
      command =>
      'multipath -F; service multipathd -F; service iscsi stop;\
      iscsiadm -m node -o delete; iscsiadm -m iface -I iface0 -o delete;\
      iscsiadm -m iface -I iface1 -o delete';
  }
}
