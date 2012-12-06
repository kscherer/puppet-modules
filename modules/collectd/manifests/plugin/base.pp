#
class collectd::plugin::base(
  $conf_file = "collectd/base.conf",
) {
  file {
    '/etc/collectd.d/base.conf':
      ensure  => present,
      notify  => Service['collectd'],
      content => template("${conf_file}.erb");
  }
}
