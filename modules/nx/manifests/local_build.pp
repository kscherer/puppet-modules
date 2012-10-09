#
class nx::local_build {
  file {
    '/home/nxadm/nx':
      ensure  => directory,
      mode    => '0755';
    ["/home/nxadm/nx/${::hostname}.1","/home/nxadm/nx/${::hostname}.2"]:
      ensure  => directory,
      mode    => '0755';
  }
}
