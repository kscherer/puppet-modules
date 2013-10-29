#
class wr::yow-lpd-puppet2 {
  include profile::monitored

  include apache
  include apache::mod::passenger
  Class['wr::common::repos'] -> Class['apache']
  Class['wr::common::repos'] -> Class['apache::mod::passenger']

  include wr::master
}
