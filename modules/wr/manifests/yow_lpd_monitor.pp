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
}
