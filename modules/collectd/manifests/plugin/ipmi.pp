#
class collectd::plugin::ipmi(
  $conf_file = "collectd/ipmi.conf",
  ) {
    file {
      '/etc/collectd.d/ipmi.conf':
        ensure  => present,
        notify  => Service['collectd'],
        content => template("${conf_file}.erb");
    }
  }
