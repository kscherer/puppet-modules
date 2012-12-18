#
class wr::ala-lpggp inherits wr::ala-common {
  class { 'yocto': }
  class { 'git': }
  Class['redhat'] -> Class['yocto']
  Class['redhat'] -> Class['git']

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

  package {
    'quilt':
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

  motd::register{
    'ala-lpggp':
      content => "This machine is for Linux Products developers manual compiles.
It is not to be used for automated testing, automated builds or
other uses. Please limit compiles to --enable-jobs=5.
Use /${::hostname}[1-2] as local storage.
It is not backed up, make sure you have a secure copy
of your data.  Clean up after yourself, this F/S will be cleaned
up periodically.";
  }
  file {
    [ "/${::hostname}1", "/${::hostname}2/"]:
      ensure => 'directory',
      group  => 'users',
      mode   => '0777';
  }
}
