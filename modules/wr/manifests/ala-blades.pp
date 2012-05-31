#
class wr::ala-blades inherits wr::mcollective {
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
  -> class { 'yocto': }

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
  }

  ssh_authorized_key {
    'root@ala-blade17':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('root@ala-blade17'),
      type   => 'ssh-rsa';
  }

  file {
    '/etc/resolv.conf':
      ensure  => present,
      mode    => '0644',
      content => "domain wrs.com\nsearch wrs.com windriver.com corp.ad.wrs.com\nnameserver 147.11.57.128\nnameserver 147.11.57.133\n";
  }
}
