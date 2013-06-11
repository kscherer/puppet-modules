#
class wr::pek-usp inherits wr::common {

  case $::operatingsystem {
    Debian,Ubuntu: { $base_class='debian' }
    CentOS,RedHat,Fedora: { $base_class='redhat' }
    OpenSuSE,SLED: { $base_class='suse'}
    default: { fail("Unsupported OS: $::operatingsystem")}
  }

  class { $base_class: }
  -> class { 'puppet': }

  ssh_authorized_key {
    'wenzong':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('wfan@pek-wenzong-fan'),
      type   => 'ssh-dss';
  }

  user {
    'build':
      ensure     => present,
      managehome => true,
      password   => '$1$build$Sd87PZQjuDV6hscqVjs9j.';
  }

  group {
    'build':
  }

  file {
    '/buildarea':
      ensure => directory,
      owner  => 'build',
      group  => 'build',
      mode   => '0755';
  }

}
