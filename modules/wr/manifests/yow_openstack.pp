#
class wr::yow_openstack {

  include profile::monitored
  include sudo

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

  include openstack::repo

  if $::hostname == 'yow-blade1' {
    include openstack::controller
    include openstack::auth_file
    include apache
    class { 'rabbitmq::repo::apt':
      before => Class['rabbitmq::server']
    }

    #controller has an lvm partition for vms as well
    include cinder::volume

    #setup cinder service on controller to use netapp
    cinder_config {
      'DEFAULT/enabled_backends': value => "netapp,lvm-${::hostname}";
      'netapp/volume_driver': value => 'cinder.volume.drivers.netapp.iscsi.NetAppDirectCmodeISCSIDriver';
      'netapp/netapp_server_hostname': value => '172.17.137.11';
      'netapp/netapp_server_port': value => 80;
      'netapp/netapp_login': value => 'root';
      'netapp/netapp_password': value => 'netapp';
    }
  } else {
    include openstack::compute
    cinder_config {
      'DEFAULT/enabled_backends': value => "lvm-${::hostname}";
      'DEFAULT/glance_host': value => 'yow-blade1.wrs.com';
    }
  }

  #Give each cinder config a backend name so it can be connected to volume type
  cinder_config {
    "lvm-${::hostname}/volume_driver": value => 'cinder.volume.drivers.lvm.LVMISCSIDriver';
    "lvm-${::hostname}/volume_group": value => 'cinder-volumes';
    "lvm-${::hostname}/volume_backend_name": value => "lvm-iscsi-${::hostname}";
    "lvm-${::hostname}/volume_clear": value => 'none';
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
