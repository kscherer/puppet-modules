#
class wr::pek-hostel inherits wr::common {

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

  case $::hostname {
    # userspace/yocto build hosts
    /^pek-hostel-vm(0[1-9]|1[0-3]).*/: {
      file {
        '/buildarea':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0777';
      }
    }

    # host testing
    default: {
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
  }
}
