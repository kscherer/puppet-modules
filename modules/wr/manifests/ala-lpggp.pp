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

  case $::hostname {
    /ala-lpggp[2-3]/: {
      motd::register{
        'ala-lpggp':
          content =>
          'This machine is reserved for Linux Products automated testing only.';
      }
      # create a directory for exclusive use by lpg-test group
      file {
        [ "/${::hostname}1", "/${::hostname}2/"]:
          ensure => 'directory',
          group  => '3815',
          mode   => '0775';
      }
    }
    default: {
      motd::register{
        'ala-lpggp':
          content => "This machine is for Linux Products developers manual compiles.
It is not to be used for automated testing, automated builds or
other uses. Please limit compiles to --enable-jobs=5.
Use /${::hostname}1 as local storage.
It is not backed up, make sure you have a secure copy
of your data.  Clean up after yourself, this F/S will be cleaned
up periodically.";
      }
    }
  }

}
