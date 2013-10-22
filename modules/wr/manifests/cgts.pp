class wr::cgts {
  class { 'wr::common': }
  -> class { 'wr::mcollective': }

  include puppet
  include debian
  include nis
  include yocto
  include nrpe

  include sudo
  sudo::conf {
    'cgts':
      source  => 'puppet:///modules/wr/sudoers.d/cgts';
  }

  package {
    [ 'nedit', 'tightvncserver', 'gitk', 'konsole', 'motif-clients', 'ddd',
      'compizconfig-settings-manager', 'gnome', 'kde-full', 'xfce4',
      'ubuntu-desktop', 'openjdk-7-jre-lib', 
      'icedtea-plugin', 'icedtea-7-plugin',
      'eclipse-platform', 'codeblocks', 'doxygen',
      'quilt', 'iotop', 
      'nfs-client', 'okular', 'openjdk-7-jre', 'parted',
      'qemu-kvm', 'rake', 'vim-nox', 'git-email']:
      ensure => latest;
  }

}
