# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir = '/etc/zookeeper/conf',
)
{
  require zookeeper::install
  include zookeeper::params

  service { 'zookeeper':
    ensure     => 'running',
    name       => $zookeeper::params::zookeeper_service,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      Package['zookeeperd'],
      File["${cfg_dir}/zoo.cfg"]
    ]
  }
}
