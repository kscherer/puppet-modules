#
class wr::ala_lpd_susbld {
  class { 'wr::ala-common': }

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
    'buildadmin_buildadmin':
      ensure => 'present',
      user   => 'buildadmin',
      key    => extlookup('buildadmin@ala-blade9'),
      type   => 'ssh-rsa';
  }

  service {
    'httpd':
      ensure => running,
      enable => true,
  }
}
