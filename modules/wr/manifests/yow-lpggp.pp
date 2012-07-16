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

  motd::register{
    'yow-lpggp':
      content => "This machine is for Linux Products developers manual
compiles.  It is not to be used for automated testing, automated
builds or other uses. Please limit compiles to --enable-jobs=5.
Use /${::hostname}1 as local storage.  It is not backed up, make
sure you have a secure copy of your data.  Clean up after
yourself, this F/S will be cleaned up periodically.";
  }
}
