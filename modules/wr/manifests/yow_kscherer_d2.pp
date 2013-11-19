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
      'nfs-client', 'parted', 'qemu-kvm', 'vim-nox', 'git-email', 'mosh']:
        ensure => latest;
  }

  include wr::common
  include debian
  include nis
}
