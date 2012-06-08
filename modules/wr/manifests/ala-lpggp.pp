#
class wr::ala-lpggp inherits wr::ala-common {
  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

  if $::hostname == 'ala-lpggp2.wrs.com' {
    file {
      '/lpg-build':
        ensure => link,
        target => '/ala-lpggp22';
    }
  }
  if $::hostname == 'ala-lpggp3.wrs.com' {
    file {
      '/lpg-build':
        ensure => link,
        target => '/ala-lpggp32';
    }
  }
}
