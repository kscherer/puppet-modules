# Class: zookeeper::params
class zookeeper::params{
  case $::osfamily {
    'Debian': {
      $zookeeper_package = 'zookeeper'
      $zookeeperd_package = 'zookeeperd'
      $zookeeper_service = 'zookeeper'
      $cron_package      = 'cron'
    }
    'RedHat': {
      $zookeeper_package = 'zookeeper'
      $zookeeperd_package = 'zookeeper-server'
      $zookeeper_service = 'zookeeper-server'
      $cron_package      = 'cronie'
    }
    default: {
      warning("Operating system ${::operatingsystem} not supported.")
    }
  }
}
