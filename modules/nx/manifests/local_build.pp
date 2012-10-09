#
class nx::local_build {
  file {
    '/home/nxadm/nx':
      ensure  => directory,
      mode    => '0755';
    "/home/nxadm/nx/${::hostname}.1":
      ensure  => directory,
      mode    => '0755';
  }
}
