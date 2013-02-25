#
define graphite::carbon::storage ( $pattern, $retentions, $order = 10){
  concat::fragment {$name:
    target  => '/etc/carbon/storage-schemas.conf',
    order   => $order,
    content => template('graphite/storage-schemas.erb'),
    require => Package['carbon'],
    notify  => Service['carbon-cache']
  }
}
