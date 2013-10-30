#
class wr::yow-lpd-puppet2 {
  include profile::monitored

  include apache
  include apache::mod::passenger
  Class['wr::common::repos'] -> Class['apache']
  Class['wr::common::repos'] -> Class['apache::mod::passenger']

  include hiera
  include puppetdb
  include puppetdb::master::config
  Class['wr::common::repos'] -> Class['puppetdb']
  Class['wr::common::repos'] -> Class['hiera'] -> Class['puppet']
  Class['puppetdb'] -> Class['puppetdb::master::config']


  include git::stomp_listener
  Class['wr::common::repos'] -> Class['git::stomp_listener']

  include apache::mod::wsgi
  include graphite
  Class['apache::mod::wsgi'] -> Class['graphite']

  include nagios
  include nagios::nsca::server

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
}
