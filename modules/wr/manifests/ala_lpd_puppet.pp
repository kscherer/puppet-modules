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

  include nagios
  include nagios::nsca::server
  Class['wr::mcollective'] -> Class['nagios']

  include wr::activemq
  include wr::foreman

  include apache::mod::wsgi
  include graphite
  Class['apache::mod::wsgi'] -> Class['graphite']

  graphite::carbon::storage {
    'default_10s_for_2weeks':
      pattern    => '.*',
      order      => '99',
      retentions => '10s:14d';
  }

  include graphite_reporter
}
