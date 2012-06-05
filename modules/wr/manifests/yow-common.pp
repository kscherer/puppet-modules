#
class wr::yow-common inherits wr::mcollective {
  class { 'redhat': }
  -> class { 'ntp':
    servers => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'collectd::client': }
  -> class { 'nagios::target': }

  file {
    '/etc/resolv.conf':
      ensure  => present,
      mode    => '0644',
      content => "domain wrs.com\nsearch wrs.com windriver.com corp.ad.wrs.com\nnameserver 128.224.144.28 \nnameserver 147.11.57.128\n";
  }

  #enable auto update using cron
  package {
    'yum-cron':
      ensure => installed;
    'yum-updatesd':
      ensure => absent;
  }
}
