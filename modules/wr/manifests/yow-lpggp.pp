#
class wr::yow-lpggp inherits wr::yow-common {
  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

  #make sure latest git is available from epel
  package {
    'git':
      ensure => 'latest';
  }

  define wr::yow-lpggp::local_file() {
    file {
      "/usr/local/bin/$name":
        ensure => 'absent';
    }
  }

  wr::yow-lpggp::local_file {
    [ '/git','gitk','git-cvsserver','git-shell','git-upload-pack',
      'git-upload-archive','git-recieve-pack']:
  }
}
