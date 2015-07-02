#
class wr::yow_lpggp {
  include profile::nis

  include yocto
  Class['wr::common::repos'] -> Class['yocto']

  include git
  Class['wr::common::repos'] -> Class['git']

  #another developer request
  package {
    ['screen', 'wiggle', 'expect', 'quilt', 'tmux']:
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
    package {
      'nfs-kernel-server':
        ensure  => installed,
        require => File['/etc/exports'];
    }

    service {
      'nfs-kernel-server':
        ensure    => running,
        require   => [ Package['nfs-kernel-server'], File['/etc/exports']];
    }

    file {
      '/etc/exports':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "/${::hostname}1 *(rw)\n/${::hostname}2 *(rw)",
        notify  => Service['nfs-kernel-server'];
    }

    # setup x2go server to provide remote graphical access
    apt::ppa { 'ppa:x2go/stable': }
    ensure_packages(['x2goserver', 'x2goserver-extensions', 'x2goserver-xsession',
                     'xterm', 'tightvncserver'])
  }
}
