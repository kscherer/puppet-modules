class wr::yow_simics {
  include nis
#  include apache
  include ntp
  include sudo

#  sudo::conf {
#	'ityow':
#	 source  => 'puppet:///modules/wr/sudoers.d/ityow';
#  }

  package {
    [ 'openssl','libssl-dev','libbz2-dev','libreadline6','libreadline6-dev','bridge-utils',
      'uml-utilities','iptables-persistent','vim',
      'xutils-dev','vsftpd','tftpd-hpa', 'libsqlite3-dev', 'tightvncserver',
      'twm','lubuntu-desktop']:
      ensure => 'installed';
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
 
}