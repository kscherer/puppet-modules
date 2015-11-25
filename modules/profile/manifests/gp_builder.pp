#
class profile::gp_builder {
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
    $::hostname:
      content => "This machine is for Linux Products developers manual
compiles.  It is not to be used for automated testing, automated
builds or other uses. Please limit compiles to --enable-jobs=5.
Use /${::hostname}1 as local storage.  It is not backed up, make
sure you have a secure copy of your data.  Clean up after
yourself, this F/S will be cleaned up periodically.";
  }

  if $::operatingsystem == 'Ubuntu' {
    include ::nfs::server
    include ::x2go
    include ::profile::docker

    # some developers are more comfortable with vnc
    ensure_packages(['tightvncserver', 'xfsprogs', 'vim-nox'])

    # packages for suite installer
    ensure_packages(['libstdc++6:i386', 'libgtk2.0-0:i386', 'libXtst6:i386'])

    concat::fragment {
      'export_buildarea':
        target  => '/etc/exports',
        content => "/${::hostname}1 *(rw)\n/${::hostname}2 *(rw)\n",
        order   => '10'
    }
  }

  #enable running docker and runqemu using sudo
  sudo::conf {
    'lpg':
      source  => 'puppet:///modules/wr/sudoers.d/lpg';
  }

  # to allow kvm access to all, make kvm device accessible to all
  # There isn't an easy way to add all lpg group members to kvm group
  file {
    '/dev/kvm':
      ensure => present,
      mode   => '0666';
  }
}
