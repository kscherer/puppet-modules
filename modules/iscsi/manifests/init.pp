#
class iscsi {

  package {
    'iscsi-initiator-utils':
      ensure => installed;
  }

  if 'em1' in $::interfaces {
    $lan_port = em1
    $san_port1 = p3p1
    $san_port2 = p1p2
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
      require    => Package['iscsi-initiator-utils'];
  }

  service {
    'iscsid':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Package['iscsi-initiator-utils'];
  }

  #configure each host based on extlookup data for each host
  iscsi::net_config {
    $lan_port:
      gateway => extlookup("${lan_port}_gateway");
  }

  $iscsi_initiator_name = extlookup('iscsi_initiator_name')

  file{
    '/etc/iscsi/initiatorname.iscsi':
      content =>
        "InitiatorName=${iscsi_initiator_name}\nInitiatorAlias=${::hostname}\n",
      require => Package['iscsi-initiator-utils'],
      notify  => Service[ 'iscsi' ],
      owner   => root, group => root, mode => '0644';
  }

  $iscsi_replacement_timeout=15
  $iscsi_noop_out_interval=5
  $iscsi_noop_out_timeout=5

  file{
    '/etc/iscsi/iscsid.conf':
      content => template('iscsi/iscsid.conf.erb'),
      require => Package['iscsi-initiator-utils'],
      notify  => Service[ 'iscsi' ],
      owner   => root, group => root, mode => '0600';
  }
}
