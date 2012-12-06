#
class collectd::plugin::write_graphite (
  $host             = 'graphite',
  $port             = '2003',
  $prefix           = '',
  $postfix          = '',
  $store_rates      = true,
  $always_append_ds = false,
  $escape_character = '_'
) {

  validate_re($host, '^[._0-9a-zA-Z:-]+$')
  validate_re($port, '^\d+$')
  $host_real = $host
  $port_real = $port
  $store_rates_real = any2bool($store_rates)
  $always_append_ds_real = any2bool($always_append_ds)

  file {
    '/etc/collectd.d/write_graphite.conf':
      ensure  => file,
      notify  => Service['collectd'],
      content => template('collectd/write_graphite.conf.erb');
  }
}
