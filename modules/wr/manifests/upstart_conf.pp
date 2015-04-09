# Single define to replace multiple file definitions for upstart configs
define wr::upstart_conf() {
  file {
    "/etc/init/${name}.conf":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/wr/${name}.conf",
      notify => Service[$name];
  }
}
