# Class: graphite
#
# This module manages graphite
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class graphite::carbon::config {
  include concat::setup
  concat { '/etc/carbon/storage-schemas.conf':
    group   => '0',
    mode    => '0644',
    owner   => '0',
    notify  => Service['carbon-cache'];
  }

  concat::fragment { 'header':
    target  => '/etc/carbon/storage-schemas.conf',
    order   => 0,
    source  => 'puppet:///modules/graphite/storage-schemas.conf'
  }

  #modifications to this file are automatically read by
  #carbon aggregation service
  concat { '/etc/carbon/aggregation-rules.conf':
    group   => '0',
    mode    => '0644',
    owner   => '0',
  }
}
