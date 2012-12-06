#
class graphite::carbon::service(
  $cache_ensure      = 'running',
  $aggregator_ensure = 'stopped',
  $client_ensure     = 'stopped',
  $relay_ensure      = 'stopped',
  $cache_enable      = true,
  $aggregator_enable = false,
  $client_enable     = false,
  $relay_enable      = false,
) {

  service { 'carbon-cache':
    ensure     => $cache_ensure,
    enable     => $cache_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['carbon'],
  }

  service { 'carbon-aggregator':
    ensure     => $aggregator_ensure,
    enable     => $aggregator_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['carbon'],
  }

  service { 'carbon-client':
    ensure     => $client_ensure,
    enable     => $client_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['carbon'],
  }

  service { 'carbon-relay':
    ensure     => $relay_ensure,
    enable     => $relay_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['carbon'],
  }

}


