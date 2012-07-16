#
class nx::yow-hostel {

  class { 'nfs': }
  -> Anchor['nx::begin']
  -> Class['nx::yow-hostel']
  -> Anchor['nx::end']

  file {
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
