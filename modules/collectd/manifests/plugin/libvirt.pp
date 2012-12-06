#
class collectd::plugin::libvirt(
  $file = 'collectd/libvirt.conf',
) {
  file {
    '/etc/collectd.d/libvirt.conf':
      ensure  => file,
      notify  => Service['collectd'],
      content => file($file);
  }
}
