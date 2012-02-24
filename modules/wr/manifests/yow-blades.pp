#
class wr::yow-blades inherits wr::mcollective {
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
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
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
}
