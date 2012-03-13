#
class wr::pek-xenserver inherits wr::mcollective {

  class { 'apt': }
  -> class { 'debian': }
  -> class { 'ntp':
    servers    => $wr::commom::ntp_servers,
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
