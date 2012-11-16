#
class wr::yow-common inherits wr::mcollective {
  class { 'redhat': }
  -> class { 'redhat::autoupdate': }
  -> class { 'ntp':
    servers => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => $wr::common::puppet_version,
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'collectd::client': }
  -> class { 'nagios::target': }
  -> class { 'sudo': }

  file {
    '/etc/resolv.conf':
      ensure  => present,
      mode    => '0644',
      content => "domain wrs.com\nsearch wrs.com windriver.com corp.ad.wrs.com\nnameserver 128.224.144.130 \nnameserver 147.11.57.128\n";
  }
}
