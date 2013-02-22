#
class wr::yow_lpd_monitor {

  class { 'wr::yow-common': mcollective_client => true}
  -> class { 'nagios': }
  -> class { 'wr::puppetcommander': }
  -> class { 'graphite': }

  #nagios class notifies httpd service so -> relationship creates cycles
  class { 'apache': }

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
    'nx-aggregrate':
      target  => '/etc/carbon/aggregation-rules.conf',
      order   => 2,
      source  => 'puppet:///modules/wr/nx-build-aggregation.conf';
  }
}
