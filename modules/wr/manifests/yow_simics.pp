#
class wr::yow_simics {
  include nis
#  include apache
  include ntp
  include sudo

  sudo::conf {
	'ityow':
	 source  => 'puppet:///modules/wr/sudoers.d/ityow';
  }

  package {
    [ 'openssl','libssl-dev','libbz2-dev','libreadline6',
      'libreadline6-dev','','bridge-utils','uml-utilities','iptables-persistent','vim',
	  'xutils-dev','vsftpd','tftpd-hpa', 'libsqlite3-dev', 'tightvncserver', 
	  'twm','lxde']:
      ensure => 'installed';
  }
#  file {
#  '/etc/samba/smb.conf':
#  ensure => present,
#  content => template('wr/samba.conf.erb');
#  }
 
#  file { '/etc/exports':
#    ensure  => present,
#    content => '/buildarea1   *(rw,insecure,async,insecure_locks) 
#/buildarea2   *(rw,insecure,async,insecure_locks) 
#/buildarea3   *(rw,insecure,async,insecure_locks) 
#/buildarea4   *(rw,insecure,async,insecure_locks)';
#  }
# 
# 
# file {	
#	"/${hostname}1/jenkins":
#	ensure	=> directory,
#	owner	=> 'svc-bld',
#	group	=> 'users',
#	mode	=> 0644;
# }

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
