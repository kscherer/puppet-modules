#
class profile::collectd {
  if $::osfamily != 'Suse' {
    include ::collectd

    $plugins = hiera_array('collectd::plugins',[])
    include $plugins
  }
}

