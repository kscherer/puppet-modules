#
class wr::ala-lpggp inherits wr::ala-common {
  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

}
