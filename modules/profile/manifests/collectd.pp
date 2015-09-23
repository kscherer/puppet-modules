#
class profile::collectd {
  include ::collectd

  $plugins = hiera_array('collectd::plugins',[])
  include $plugins
}

