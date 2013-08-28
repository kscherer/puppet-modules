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

  package {
    'ubuntu-cloud-keyring':
      ensure => installed;
  }

  include debian
  include apache

  apt::source {
    'ubuntu_cloud_archive':
      location    => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
      release     => 'precise-updates/grizzly',
      repos       => 'main',
      include_src => false;
  }

  if $::hostname == 'yow-blade1' {
    include openstack::controller
    include openstack::auth_file

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
}
