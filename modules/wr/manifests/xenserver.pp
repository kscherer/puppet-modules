#
class wr::xenserver inherits wr::mcollective {

  class { 'apt': purge_sources_list => true }
  class { 'debian': }
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
  -> class { 'collectd::client': }
  -> class { 'nagios::target': }
  -> class { 'xen': }

  #make sure mcollective package does not try to install packages until
  #sources have been installed
  Class['debian'] -> Class['mcollective']

  #set a strong generated password to encourage use of ssh authorized keys
  user {
    'root':
      password => '$6$lWv2aSVT1/Yd$yVsrcIydMlcq4fkB23EDq6zZSmnR0Ab0NskE39YVODV9fcIl/MLLa4EplwSR4x/EqDX6O/H8Q7CwpLHUdEZpn0';
  }
}
