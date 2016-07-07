# common class to hold creation of wrlbuild user and group

class profile::mesos::wrlbuild {
  # Create account which can be used by mesos slaves to transfer files to fileserver
  group {
    'wrlbuild':
      ensure => present,
  }

  # group created by docker package, must be declared here so that wrlbuild
  # can be in docker group
  group {
    'docker':
      ensure  => present,
      require => Class['docker'];
  }

  user {
    'wrlbuild':
      ensure         => present,
      gid            => 'wrlbuild',
      uid            => 1000,
      managehome     => true,
      home           => '/home/wrlbuild',
      groups         => ['users', 'docker'],
      shell          => '/bin/bash',
      password       => '$5$6F1BpKqFcszWi0n$fC5yUBkPNXHfyL8TOJwdJ1EE8kIzwJnKVrtcFYnpbcA',
      require        => [ Group['wrlbuild'], Group['docker']];
  }

  ssh_authorized_key {
    'kscherer_desktop_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('kscherer@yow-kscherer-d1'),
      type   => 'ssh-rsa';
    'kscherer_home_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('kscherer@helix'),
      type   => 'ssh-rsa';
  }
}
