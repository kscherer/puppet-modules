#
class wr::yow-hostel inherits wr::mcollective {

  case $::operatingsystem {
    Debian,Ubuntu: { $base_class='debian' }
    CentOS,RedHat,Fedora: { $base_class='redhat' }
    default: { fail("Unsupported OS: $::operatingsystem")}
  }

  class { $base_class: }
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
  -> class { 'nis': }
  -> class { 'wrlinux': }
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
}
