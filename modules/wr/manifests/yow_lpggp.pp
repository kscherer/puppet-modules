#
class wr::yow_lpggp {
  include profile::nis

  include yocto
  Class['wr::common::repos'] -> Class['yocto']

  include git
  Class['wr::common::repos'] -> Class['git']

  #another developer request
  package {
    ['screen', 'wiggle', 'expect', 'quilt', 'tmux', 'curl', 'wget']:
      ensure => installed;
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

  if $::operatingsystem == 'Ubuntu' {
    include nfs::server
    include x2go
    include docker

    # some developers are more comfortable with vnc
    ensure_packages(['tightvncserver'])

    concat::fragment {
      'export_buildarea':
        target  => '/etc/exports',
        content => "/${::hostname}1 *(rw)\n/${::hostname}2 *(rw)\n",
        order   => '10'
    }
  }
}
