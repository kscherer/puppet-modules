#
class collectd::plugin::ipmi(
  $conf_file = 'collectd/ipmi.conf',
  ) {
    #only enable ipmi sensor testing on bare metal
    $is_virtual_bool = any2bool($::is_virtual)
    $is_bare_metal=($is_virtual_bool == false and $::manufacturer =~ /Dell/)

    if $is_bare_metal {
      file {
        '/etc/collectd.d/ipmi.conf':
          ensure  => present,
          notify  => Service['collectd'],
          content => template("${conf_file}.erb");
      }
    }
  }
