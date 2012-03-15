#
class wr::yow-lpgbuild inherits wr::mcollective {
  class { 'redhat': }
  -> class { 'ntp':
    servers    => ['ntp-1.wrs.com','ntp-2.wrs.com'],
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
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

  ssh_authorized_key {
    'kscherer_windriver_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => $wr::common::kscherer_windriver_pubkey,
      type   => 'ssh-dss';
    'kscherer_home_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => $wr::common::kscherer_home_pubkey,
      type   => 'ssh-rsa';
  }

  file {
    '/etc/resolv.conf':
      ensure  => present,
      mode    => '0644',
      content => "domain wrs.com\nsearch wrs.com\nnameserver 128.224.144.28";
  }
}
