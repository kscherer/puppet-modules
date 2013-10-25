#
class wr::yow_kscherer_d1 {
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
    [ 'thunderbird','git','chromium-browser','konversation','emacs24','amarok',
      'dmidecode', 'dos2unix', 'ethtool', 'flac', 'firefox', 'flashplugin-installer',
      'fwknop-client', 'gnupg', 'puppet', 'keepassx', 'kpartx', 'konsole',
      'latex-beamer', 'kvpnc', 'nfs-client', 'okular', 'openjdk-7-jre', 'parted',
      'qemu-kvm', 'rake', 'vim-nox', 'git-email', 'rubygems', 'mosh']:
      ensure => latest;
  }

  include wr::common
  include debian
  include nis
}
