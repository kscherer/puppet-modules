#
class wr::ala-lpd-susbld {
  class { 'wr::common': }

  group {
    'buildadmin':
      ensure => present,
  }

  user {
    'buildadmin':
      ensure     => present,
      home       => '/home/buildadmin',
      gid        => 'buildadmin',
      managehome => true;
  }

  ssh_authorized_key {
    'pkennedy_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('pkennedy@linux-y9cs.site'),
      type   => 'ssh-dss';
    'wenzong_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('wfan@pek-wenzong-fan'),
      type   => 'ssh-dss';
  }
}
