#
class wr::pek-xenserver inherits wr::mcollective {

  class { 'apt': purge_sources_list => true }
  -> class { 'debian': }
  -> class { 'ntp':
    servers    => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'xen': }
}
