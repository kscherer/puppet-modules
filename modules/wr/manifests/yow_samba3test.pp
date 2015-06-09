#
class wr::yow_samba3test {
  include nis
  include apache
  include ntp
  include sudo
 # include jenkins

  sudo::conf {
    'test':
      source  => 'puppet:///modules/wr/sudoers.d/test';
	'ityow':
	 source  => 'puppet:///modules/wr/sudoers.d/ityow';
    
  }

  package {
    [ 'tzdata-java',
      'gnome','libstdc++6:i386','libgtk2.0-0:i386','libxtst6:i386','bc','vim',
	  'xutils-dev','expect','openssh-server', 'vnc4server', 'nfs-server', 
	  'rsh-client', 'rsh-server', 'apache2-mpm-prefork','xinetd',
	  'tftp','tftpd','telnetd','minicom','screen','spawn-fcgi',
	  'tcl-dev:amd64','tcl8.5-dev:amd64','icedtea-7-plugin','bum',
	  'sysv-rc-conf','ksh','ethtool','xutils','gsfonts-x11','scrollkeeper',
	  'groff','time','acl','gawk','xsltproc','flex','tcl','apt-file','cabal-install',
	  'cheese-common','clisp','alex','dos2unix','fakeroot','happy','haskell-mode',
	  'highlight','highlight-common','iproute','zlib1g:i386','zlib1g-dev:amd64',
	  'createrepo','git','autoconf','automake','libtool','g++',
	  'gcc','gcc-4.6','gcc-4.6-base:amd64','gcc-4.7','gcc-4.7-base:amd64',
	  'gcc-multilib','libcanberra-gtk-module','comerr-dev','linux-headers-generic',
	  'cpp-4.6','curl','dpkg-dev','emacs','emacs23','emacs23-bin-common',
	  'emacs23-common','emacs23-common-non-dfsg','emacs24','emacs24-bin-common',
	  'emacs24-common','emacs24-common-non-dfsg','emacsen-common','freeglut3',
	  'freeglut3-dev:amd64','gamin','ghc','ghc-haddock','jove', 'twm','lxde', 'mailutils']:
      ensure => 'installed';
  }
 #file {
#	'/etc/samba/smb.conf':
#	ensure => present,
#	content => template('wr/samba.conf.erb');
# }
 
 file {
	'/etc/exports':
	ensure => present,
	content => "/${hostname}1   *(rw,insecure,async,insecure_locks)";
  }
 
 
 file {
	"/${hostname}1/jenkins":
	ensure	=> directory,
	owner	=> 'svc-bld',
	group	=> 'users',
	mode	=> 0644;
 }
 #Allow Root Login
 file {
	'/etc/ssh/sshd_config':
	ensure => present,
	}->
	file_line { 'Allow Root login':
  path => '/etc/ssh/sshd_config',  
  line => 'PermitRootLogin yes',
  match   => "^PermitRootLogin .*$",
  }

  ### Samba 3 Test install script
  
  package { ['samba']:
    ensure => 'purged';
  }
  
  exec { "install_Samba":
          command => "/folk/rvandenb/scripts/samba",
          creates => "/usr/bin/smbd",
	  require => Class["nis"];
  }
  
}

