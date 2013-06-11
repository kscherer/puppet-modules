#
class wr::yow-common( $mcollective_client = false ) {
  class { 'wr::yow_dns': }
  class { 'redhat': }
  -> class { 'redhat::autoupdate': }
  -> class { 'wr::common': }
  -> class { 'wr::mcollective': client => $mcollective_client }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'nagios::target': }
  -> class { 'sudo': }

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
    'leads':
      source  => 'puppet:///modules/wr/sudoers.d/leads';
  }
}
