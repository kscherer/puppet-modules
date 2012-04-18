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

  user {
    'test':
      ensure     => present,
      managehome => true,
      password   => sha1('windriver');
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
