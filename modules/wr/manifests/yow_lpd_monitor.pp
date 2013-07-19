#
class wr::yow_lpd_monitor {

  class { 'wr::yow-common': mcollective_client => true}

  include nagios
  include nagios::nsca::server
  include graphite

  #nagios class notifies httpd service so -> relationship creates cycles
  include apache
  include apache::mod::wsgi

  graphite::carbon::storage {
    'nx_build_stats':
      pattern    => '^nx\.',
      retentions => '60:60d';
    'default_10s_for_2weeks':
      pattern    => '.*',
      order      => '99',
      retentions => '10s:14d';
  }

  #concat is another possible extension point
  concat::fragment {
    'cpu-aggregrate':
      target  => '/etc/carbon/aggregation-rules.conf',
      order   => 1,
      source  => 'puppet:///modules/wr/cpu-aggregation.conf';
    'nx-aggregrate':
      target  => '/etc/carbon/aggregation-rules.conf',
      order   => 2,
      source  => 'puppet:///modules/wr/nx-build-aggregation.conf';
  }
}
