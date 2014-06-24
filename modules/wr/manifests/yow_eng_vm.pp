#
class wr::yow_eng_vm {
  include nis
  include apache
  include ntp

  package {
    [ 'tzdata-java','openjdk-7-jdk','openjdk-7-jre','openjdk-7-jre-headless',
      'python26', 'mrepo', 'python-ssl', 'mirrormanager-client', 'db4-devel',
      'libstdc++6:i386','libgtk2.0-0:i386','libxtst6:i386','bc','vim',
	  'xutils-dev','expect','openssh-server', 'vnc4server', 
	  'rsh-client', 'rsh-server', 'apache2-mpm-prefork','xinetd',
	  'tftp','tftpd','telnetd','minicom','samba','screen','spawn-fcgi',
	  'tcl-dev:amd64','tcl8.5-dev:amd64','icedtea-7-plugin','bum',
	  'sysv-rc-conf','ksh','ethtool','xutils','gsfonts-x11','scrollkeeper',
	  'groff','time','acl','gawk','xsltproc','flex','tcl','apt-file','cabal-install',
	  'cheese-common','clisp','alex','dos2unix','fakeroot','happy','haskell-mode',
	  'highlight','highlight-common','iproute','zlib1g:i386','zlib1g-dev:amd64',
	  'createrepo','rpmbuild','git','autoconf','automake','libtool','g++',
	  'gcc','gcc-4.6','gcc-4.6-base:amd64','gcc-4.7','gcc-4.7-base:amd64',
	  'gcc-multilib','libcanberra-gtk-module','comerr-dev','linux-headers-generic',
	  'cpp-4.6','curl','dpkg-dev','emacs','emacs23','emacs23-bin-common',
	  'emacs23-common','emacs23-common-non-dfsg','emacs24','emacs24-bin-common',
	  'emacs24-common','emacs24-common-non-dfsg','emacsen-common','freeglut3',
	  'freeglut3-dev:amd64','gamin','ghc','ghc-haddock','ubuntu-desktop']:
      ensure => 'installed';
  }

}
