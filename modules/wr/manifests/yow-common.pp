#
class wr::yow-common( $mcollective_client = false ) {
  class { 'wr::yow_dns': }
  class { 'redhat': }
  -> class { 'redhat::autoupdate': }
  -> class { 'wr::mcollective': client => $mcollective_client }
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
  -> class { 'nis': }
  -> class { 'nagios::target': }
  -> class { 'sudo': }

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
  }
}
