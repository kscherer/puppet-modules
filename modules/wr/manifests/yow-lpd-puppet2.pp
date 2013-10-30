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
  include git::stomp_listener

  Class['wr::common::repos'] -> Class['puppetdb']
  Class['wr::common::repos'] -> Class['dashboard']
  Class['wr::common::repos'] -> Class['hiera']
  Class['wr::common::repos'] -> Class['git::stomp_listener']

}
