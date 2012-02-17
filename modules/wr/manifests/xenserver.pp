#
class wr::xenserver inherits wr::mcollective {

  class { 'apt': }
  -> class { 'debian': }
  -> class { 'ntp':
    servers    => ['yow-lpgbld-master.ottawa.wrs.com'],
  }
  -> class { 'puppet':
    puppet_server               => 'yow-lpd-puppet.ottawa.wrs.com',
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'collectd::client': }
  -> class { 'nagios::target': }
  -> class { 'xen': }

  user {
    'root':
      password => '$6$lWv2aSVT1/Yd$yVsrcIydMlcq4fkB23EDq6zZSmnR0Ab0NskE39YVODV9fcIl/MLLa4EplwSR4x/EqDX6O/H8Q7CwpLHUdEZpn0';
  }
}
