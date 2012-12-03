#
class collectd::disable {
  package { 'collectd':
    ensure => absent,
  }

  service { 'collectd':
    ensure => stopped,
    enable => false,
  }
}
