#
class wr::yow_osc {
  include nis
  include apache
  include ntp

  package {
    [ 'tzdata-java','openjdk-7-jdk','openjdk-7-jre','openjdk-7-jre-headless',
      'python26', 'mrepo', 'python-ssl', 'mirrormanager-client', 'db4-devel',
      'libstdc++6:i386','libgtk2.0-0:i386','libxtst6:i386','bc','vim','vim-gnome',
      'vim-runtime','xutils-dev','git','git-gui','gitk','rpm','rpm2cpio','rpm-common','expect']:
      ensure => 'installed';
  }

}
