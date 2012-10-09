#
class wr::ala-common {
  class {'wr::ala_dns': }
  -> class { 'wr::common': }
  -> class { 'redhat': }
  -> class { 'ntp':
    servers => $wr::common::ntp_servers,
  }
  -> class { 'wr::mcollective': }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => $wr::common::puppet_version,
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'nis': }

  class { 'nagios::target': }
}
