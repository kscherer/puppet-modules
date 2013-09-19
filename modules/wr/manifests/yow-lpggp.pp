#
class wr::yow-lpggp {
  class { 'yocto': }
  Class['redhat'] -> Class['yocto']

  include profile::nis
  include git

  package {
    ['quilt', 'wiggle']:
      ensure => 'latest';
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
