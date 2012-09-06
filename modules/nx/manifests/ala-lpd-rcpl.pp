#
class nx::ala-lpd-rcpl {
  include nx::ala_local_build
  nx::setup { ['1','2']: }
  
  file {
    '/data/nx':
      ensure => directory,
      owner  => 'nxadm',
      group  => 'nxadm';
    '/ala-lpd-rcpl1':
      ensure => link,
      target => '/data/nx';
  }
  
}
