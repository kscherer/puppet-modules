#This class overwrites the host ssh keys of the system
class ssh {

  file { '/etc/ssh/' :
    ensure => directory,
    mode   => '0755',
    owner  => root,
    group  => root
  }

  file {
    [ 'ssh_known_hosts','ssh_config','ssh_host_rsa_key',
      'ssh_host_rsa_key.pub','ssh_host_dsa_key','ssh_host_dsa_key.pub']:
      path    => "/etc/ssh/$name",
      mode    => '0600',
      owner   => root,
      group   => root,
      backup  => false,
      require => File['/etc/ssh'],
      source  => "puppet:///modules/ssh/$name";
  }

  #load authorized keys on managed systems
  $kscherer_yow_key=extlookup('kscherer@yow-kscherer-l1')
  $kscherer_helix_key=extlookup('kscherer@helix')

  Ssh_authorized_keys {
    ensure => present,
    type   => 'ssh-dss',
    user   => [ 'root','nxadm'],
  }

  ssh_authorized_keys {
    'kscherer@yow-kscherer-l1':
      key => $kscherer_yow_key;
    'kscherer@helix':
      key => $kscherer_helix_key;
  }
}
