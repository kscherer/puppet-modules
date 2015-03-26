#
class wr::ala_lpd_puppet {

  include profile::monitored

  include apache
  include apache::mod::passenger
  apache::listen { '80': }

  Class['wr::common::repos'] -> Class['apache']
  Class['wr::common::repos'] -> Class['apache::mod::passenger']

  include hiera
  include puppetdb
  include puppetdb::master::config
  Class['wr::common::repos'] -> Class['puppetdb']
  Class['wr::common::repos'] -> Class['hiera']
  Class['puppetdb'] -> Class['puppetdb::master::config']


  include git::stomp_listener
  Class['wr::common::repos'] -> Class['git::stomp_listener']

  include apache::mod::wsgi
  include graphite
  Class['apache::mod::wsgi'] -> Class['graphite']

  include nagios
  include nagios::nsca::server
  Class['wr::mcollective'] -> Class['nagios']

  graphite::carbon::storage {
    'default_10s_for_2weeks':
      pattern    => '.*',
      retentions => '10s:14d',
  }

  #concat is another possible extension point
  concat::fragment {
    'cpu-aggregrate':
      target  => '/etc/carbon/aggregation-rules.conf',
      order   => 1,
      source  => 'puppet:///modules/wr/cpu-aggregation.conf';
  }

  include wr::activemq
  include wr::foreman
  include collectd
  include graphite_reporter

  # monitor the health of the zookeeper cluster
  # No easy way to generate the list of zookeeper servers right now
  @@nagios_command {
    'check_zookeeper':
      command_line => '$USER1$/check_zookeeper.py -s "ala-lpd-mesos:2181,lpd-web:2181,ala-lpd-provision:2181,yow-lpd-provision:2181,pek-lpd-puppet:2181" -o nagios -k zk_num_alive_connections -w 0 -c 0';
  }

  @@nagios_service {
    'check_zookeeper':
      use                 => 'generic-service',
      check_command       => 'check_zookeeper',
      service_description => 'Zookeeper',
      host_name           => $::fqdn,
  }
}
