#
class wr::pek-hostel inherits wr::common {

  case $::operatingsystem {
    Debian,Ubuntu: { $base_class='debian' }
    CentOS,RedHat,Fedora: { $base_class='redhat' }
    OpenSuSE,SLED: { $base_class='suse'}
    default: { fail("Unsupported OS: $::operatingsystem")}
  }

  class { $base_class: }
  -> class { 'ntp':
    servers    => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }

  ssh_authorized_key {
    'wenzong':
      ensure => 'present',
      user   => 'root',
      key    => $wr::common::wenzong_pubkey,
      type   => 'ssh-dss';
  }

  user {
    'test':
      ensure     => present,
      managehome => true,
      #sha-256 salted password windriver as requested by test team
      password   => '$5$j5Wrmm4w$nsn03xSKYNSsUo1BmJqJZ3S1plhVZEMWzv7FajdZ7.B';
  }

  group {
    'test':
  }

  file {
    '/buildarea':
      ensure => directory,
      owner  => 'test',
      group  => 'test',
      mode   => '0755';
  }

}
