#
class profile::nxbuilder inherits profile::nis {
  include nx
  include yocto

  motd::register{
    'ala-blade':
      content => 'This machine is reserved for WR Linux release and coverage builds.';
  }
}
