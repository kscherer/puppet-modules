#
class wr::ala-lpd-puppet {
  class {'wr::ala_dns': }
  -> class { 'redhat': }
  -> class { 'ntp': }
  -> class { 'wr::activemq': broker_name => 'ala-broker' }
  -> class { 'wr::master': }
  -> class { 'git::stomp_listener': }
  -> class { 'graphite': }

  Class['redhat'] -> class { 'nrpe': }
  class { 'nagios': }
  class { 'nagios::target': }

  realize( Redhat::Yum_repo['graphite'] )
  Yumrepo['graphite'] -> Class['graphite']

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
