#class wr::yow_ovp_rhel {  include nis  include apache  include ntp  include sudo    sudo::conf {     'test':       source  => 'puppet:///modules/wr/sudoers.d/test'; 	'ityow': 	 source  => 'puppet:///modules/wr/sudoers.d/ityow';     'ovp': 	source   => 'puppet:///modules/wr/sudoers.d/ovp';   }
   file { 	'/etc/samba/smb.conf': 	ensure => present, 	content => template('wr/samba.conf.erb');  }    file { 	'/etc/exports': 	ensure => present, 	content => '/buildarea1   *(rw,insecure,async,insecure_locks) 	/buildarea2   *(rw,insecure,async,insecure_locks) 	/buildarea3   *(rw,insecure,async,insecure_locks) 	/buildarea4   *(rw,insecure,async,insecure_locks)';   
   }   }