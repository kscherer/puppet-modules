#
class wr::yow_rmacleod_lx4 {
  user {
    'rmacleod':
      ensure => present,
      uid    => '17365',
      gid    => 'kscherer',
      shell  => '/bin/bash',
      home   => '/home/rmacleod',
      groups => ['users','adm','sudo'],
  }

  group {
    'rmacleod':
      ensure => present,
      gid    => '1000',
  }

  package {
    [ 'git', 'dmidecode','puppet', 'kpartx', 'konsole', 'intel-microcode',
      'parted', 'qemu-kvm', 'vim-nox', 'git-email', 'mosh', 'cgroup-bin',
      'lxc']:
        ensure => latest;
  }

  include wr::common
  include debian
  include nis

  file {
    '/buildarea/rmacleod/':
      ensure => directory,
      owner  => 'rmacleod',
      group  => 'rmacleod',
      mode   => '0755';
  }
}
