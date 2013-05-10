#
class wr::yow_openstack inherits wr::mcollective {

  class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => $wr::common::puppet_version,
    puppet_agent_service_enable => false,
    agent                       => true,
  }
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

  class {
    'openstack::all':
      public_address       => $::ipaddress,
      public_interface     => 'eth0',
      private_interface    => 'eth2',
      floating_range       => '128.224.137.192/27',
      admin_email          => 'Konrad.Scherer@windriver.com',
      admin_password       => 'admin_password',
      mysql_root_password  => 'mysql_pass',
      keystone_db_password => 'keystone_db_password',
      keystone_admin_token => 'keystone_admin_token',
      nova_db_password     => 'nova_db_password',
      nova_user_password   => 'nova_user_password',
      glance_user_password => 'glance_user_password',
      glance_db_password   => 'glance_db_password',
      rabbit_password      => 'rabbit_password',
      rabbit_user          => 'openstack',
      libvirt_type         => 'kvm',
      fixed_range          => '10.193.219.0/24',
      secret_key           => 'dummy_secret_key',
      quantum              => false,
  }

  class { 'openstack::auth_file':
    admin_password       => 'admin_password',
    controller_node      => '127.0.0.1',
    keystone_admin_token => 'keystone_admin_token',
  }
}
