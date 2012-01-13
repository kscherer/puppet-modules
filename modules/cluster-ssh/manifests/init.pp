#
define clustersshfile( $path ) {
  file {
    $name :
      path => "$path/$name",
      mode => 600,
      owner => root,
      group => root,
      backup => false,
      require => File[ "$path" ],
      source => "puppet:///modules/cluster-ssh/$name";
  }
}

class cluster-ssh {

  file { "/root/.ssh/" :
    ensure => directory,
    mode => 700,
    owner => root,
    group => root
  }
  file { "/etc/ssh/" :
    ensure => directory,
    mode => 755,
    owner => root,
    group => root
  }

  clustersshfile {
    "ssh_known_hosts" :
      path => "/etc/ssh";
    "ssh_config" :
      path => "/etc/ssh";
    "ssh_host_rsa_key" :
      path => "/etc/ssh";
    "ssh_host_rsa_key.pub" :
      path => "/etc/ssh";
    "ssh_host_dsa_key" :
      path => "/etc/ssh";
    "ssh_host_dsa_key.pub" :
      path => "/etc/ssh";
    "authorized_keys" :
      path=> "/root/.ssh";
    "id_dsa" :
      path => "/root/.ssh";
    "id_dsa.pub" :
      path => "/root/.ssh";
  }
}
