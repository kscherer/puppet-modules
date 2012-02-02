#
class wr::yow-blades inherits wr::common {
  class { 'redhat': }
  -> class { 'ntp':
    servers    => ['ntp-1.wrs.com','ntp-2.wrs.com'],
    autoupdate => true,
  }
  -> class { 'wr::mcollective': }
  -> class { 'puppet':
    puppet_server               => 'yow-lpd-puppet.ottawa.wrs.com',
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'collectd::client': }
  -> class { 'wrlinux': }
  -> class { 'nx': }
}
