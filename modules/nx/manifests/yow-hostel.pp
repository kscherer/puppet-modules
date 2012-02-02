#
class nx::yow-hostel {

  class { 'nfs': }
  -> Anchor['nx::begin']
  -> Class['nx']
  -> Class['nx::yow-hostel']
  -> Anchor['nx::end']

  file {
    '/mnt/prebuilt_cache':
      ensure => directory,
      user   => root,
      group  => root;
    '/home/nxadm/nx':
      ensure  => directory;
    "/home/nxadm/nx/${::hostname}.1":
      ensure  => directory;
  }

  nx::setup {
    '1':
      require => File['/home/nxadm/nx'];
  }

  #make sure the prebuilt cache is mounted
  mount {
    'nfs_prebuilt_cache':
      ensure   => mounted,
      atboot   => true,
      device   => 'yow-lpggp1:/yow-lpggp15/prebuilt_cache/',
      name     => '/mnt/prebuilt_cache',
      fstype   => 'nfs',
      options  => 'ro,soft,auto,nolock',
      require  => File[ '/mnt/prebuilt_cache' ],
      remounts => false;
  }
}
