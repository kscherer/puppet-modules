#
class wr::yow_openstack {

  include wr::yow-common
  include dell

  user {
    'root':
      password => '$1$5VSxF7IZ$.yx57bNrz.RCFQRnz3KYV0';
  }

  motd::register{
    'openstack':
      content => 'This machine is a test OpenStack machine.';
  }

  class {
    'openstack::all':
      public_address       => $::ipaddress,
      public_interface     => 'em1',
      private_interface    => 'p3p1',
      floating_range       => '128.224.137.128/26',
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
      fixed_range          => '10.0.0.0/24',
      secret_key           => 'dummy_secret_key',
  }
}
