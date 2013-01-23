#
class collectd::disable {
  #remove the package, which will disable the service as well
  package { 'collectd':
    ensure => absent,
  }
}
