#
class wr::yow_openstack {

  class { 'wr::common': }
  -> class { 'wr::mcollective': }

  include puppet
  include sudo
  include nrpe

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
    'openstack':
      source  => 'puppet:///modules/wr/sudoers.d/openstack';
  }

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
  }

  motd::register{
    'openstack':
      content => 'This machine is a test OpenStack machine.';
  }

  include debian
  include openstack::repo

  if $::hostname == 'yow-blade1' {
    include openstack::controller
    include openstack::auth_file
    include apache
    class { 'rabbitmq::repo::apt':
      before => Class['rabbitmq::server']
    }
  } else {
    include openstack::compute
  }

  #Protect this file which is needed by cinder-common package from puppet purge of sudoers.d
  file {
    '/etc/sudoers.d/cinder_sudoers':
      ensure => present;
  }

  ssh_authorized_key {
    'bruce@yow-bashfiel-d1':
      ensure => 'present',
      user   => 'root',
      key    => hiera('bruce@yow-bashfiel-d1'),
      type   => 'ssh-dss';
  }
}
