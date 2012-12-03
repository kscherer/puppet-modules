#
class wr::yow_lpd_monitor {

  class { 'wr::yow_dns': }
  class { 'redhat': }
  -> class { 'redhat::autoupdate': }
  -> class { 'wr::mcollective': client => true }
  -> class { 'ntp':
    servers => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => $wr::common::puppet_version,
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'wr::puppetcommander': }
  -> class { 'nagios': }
  -> class { 'nis': }
  -> class { 'collectd::client': }
  -> class { 'graphite': }

  class { 'nagios::target': }

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
