#
class wr::yow-lpgbuild inherits wr::mcollective {
  class { 'redhat': }
  -> class { 'ntp':
    servers    => ['ntp-1.wrs.com','ntp-2.wrs.com'],
  }
  -> class { 'puppet':
    puppet_server               => 'yow-lpd-puppet.ottawa.wrs.com',
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'wrlinux': }
  -> class { 'collectd::client': }
  -> class { 'nx': }
  -> class { 'nagios::target': }

  user {
    'root':
      password => '$6$p6ikdyj/GHN7Uno3$VDlbq91Mp5osT0yLxVTbtDhhidFYTK7r/2xM5426g6bbesNzfhaXditRBSieRwsgpNJIbYEQhA7SZcXdf.VcZ0';
  }

  Ssh_authorized_key['kscherer_windriver'] {
    user +> 'nxadm'
  }
  Ssh_authorized_key['kscherer_home'] {
    user +> 'nxadm'
  }
}
