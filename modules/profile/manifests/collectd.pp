#
class profile::collectd {
  #include ::collectd

  #$plugins = hiera_array('collectd::plugins',[])
  #include $plugins

  # disable collectd until I have somewhere to send the stats
  # service {
  #   'collectd':
  #     ensure  => stopped,
  #     enable  => false;
  # }

}

