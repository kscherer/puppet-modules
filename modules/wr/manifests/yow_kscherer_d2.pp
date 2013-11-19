#
class wr::yow_kscherer_d2 {
  user {
    'kscherer':
      ensure => present,
      uid    => '17298',
      gid    => 'kscherer',
      shell  => '/bin/bash',
      home   => '/home/kscherer',
      groups => ['users','adm'],
  }

  group {
    'kscherer':
      ensure => present,
      gid    => '1000',
  }

  package {
    [ 'git', 'dmidecode','puppet', 'kpartx', 'konsole',
      'parted', 'qemu-kvm', 'vim-nox', 'git-email', 'mosh']:
        ensure => latest;
  }

  ssh_authorized_key {
    'kscherer_desktop_user':
      ensure => 'present',
      user   => 'kscherer',
      key    => hiera('kscherer@yow-kscherer-d1'),
      type   => 'ssh-rsa';
    'kscherer_home_user':
      ensure => 'present',
      user   => 'kscherer',
      key    => hiera('kscherer@helix'),
      type   => 'ssh-rsa';
  }

  include wr::common
  include debian
  include nis

  file {
    '/home/kscherer/.bashrc':
      ensure => present,
      owner  => 'kscherer',
      group  => 'kscherer',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/home/kscherer/.aliases':
      ensure => present,
      owner  => 'kscherer',
      group  => 'kscherer',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/home/kscherer/.bash_profile':
      ensure  => present,
      owner   => 'kscherer',
      group   => 'kscherer',
      mode    => '0755',
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }
}
