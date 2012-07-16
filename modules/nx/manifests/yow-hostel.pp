#
class nx::yow-hostel {

  class { 'nfs': }
  -> Anchor['nx::begin']
  -> Class['nx::yow-hostel']
  -> Anchor['nx::end']

  file {
    '/mnt/prebuilt_cache':
      ensure => directory,
      owner  => '8023',
      group  => '100';
    '/home/nxadm/nx':
      ensure  => directory;
    "/home/nxadm/nx/${::hostname}.1":
      ensure  => directory;
  }

  nx::setup {
    '1':
      require => File['/home/nxadm/nx'];
  }
}
