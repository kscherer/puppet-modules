#
class profile::collectd {
  if $::operatingsystem != 'SLED' {
    include ::collectd

    $plugins = hiera_array('collectd::plugins',[])
    include $plugins
  }
}

