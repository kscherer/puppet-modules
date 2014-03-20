#
class collectd::plugin::vmem(
  $conf_file = 'collectd/vmem.conf',
  $verbose = false
) {
  file {
    '/etc/collectd.d/vmem.conf':
      ensure  => file,
      notify  => Service['collectd'],
      content => template("${conf_file}.erb");
  }
}
