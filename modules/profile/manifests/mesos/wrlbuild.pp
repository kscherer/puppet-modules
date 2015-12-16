# common class to hold creation of wrlbuild user and group

class profile::mesos::wrlbuild {
  # Create account which can be used by mesos slaves to transfer files to fileserver
  group {
    'wrlbuild':
      ensure => present,
  }

  user {
    'wrlbuild':
      ensure         => present,
      gid            => 'wrlbuild',
      uid            => 1000,
      managehome     => true,
      home           => '/home/wrlbuild',
      groups         => ['users'],
      shell          => '/bin/bash',
      password       => '$5$6F1BpKqFcszWi0n$fC5yUBkPNXHfyL8TOJwdJ1EE8kIzwJnKVrtcFYnpbcA',
      require        => Group [ 'wrlbuild' ];
  }
}
