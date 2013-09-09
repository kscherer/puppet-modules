#
class wr::ala_lpgweb {
  include profile::nis

  #some packages needed to run perl CQ scripts
  ensure_resource('package', 'libdate-manip-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'liburi-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libxml-simple-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'libxml-twig-perl', {'ensure' => 'latest'})

  #some packages needed by jch's personal scripts
  ensure_resource('package', 'libnet-ldap-perl', {'ensure' => 'latest'})
  ensure_resource('package', 'liblocale-subcountry-perl', {'ensure' => 'latest'})
}
