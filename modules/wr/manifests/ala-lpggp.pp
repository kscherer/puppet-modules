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

  #make sure latest git is available from epel
  package {
    'git':
      ensure => 'latest';
  }

  define wr::ala-lpggp::local_file() {
    file {
      "/usr/local/bin/$name":
        ensure => 'absent';
    }
  }

  wr::ala-lpggp::local_file {
    [ '/git','gitk','git-cvsserver','git-shell','git-upload-pack',
      'git-upload-archive','git-recieve-pack']:
  }
}
