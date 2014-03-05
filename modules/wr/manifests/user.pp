# reduce boilerplate with user definition
define wr::user( $password ) {
  user {
    $name:
      ensure     => present,
      groups     => $name,
      home       => "/home/${name}",
      shell      => '/bin/bash',
      managehome => true,
      password   => $password;
  }

  group {
    $name:
      ensure => present;
  }

  ssh_authorized_key {
    "kscherer_desktop_${name}":
      ensure => 'present',
      user   => $name,
      key    => hiera('kscherer@yow-kscherer-d1'),
      type   => 'ssh-rsa';
    "kscherer_home_${name}":
      ensure => 'present',
      user   => $name,
      key    => hiera('kscherer@helix'),
      type   => 'ssh-rsa';
  }

  file {
    "/home/${name}/.bashrc":
      ensure => present,
      owner  => $name,
      group  => $name,
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    "/home/${name}/.aliases":
      ensure => present,
      owner  => $name,
      group  => $name,
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    "/home/${name}/.bash_profile":
      ensure  => present,
      owner   => $name,
      group   => $name,
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }
}
