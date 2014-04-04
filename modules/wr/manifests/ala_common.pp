#
class wr::ala_common {
  class {'wr::ala_dns': }
  -> class { 'redhat': }
  -> class { 'wr::common': }
  -> class { 'wr::mcollective': }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'sudo': }

  class { 'nagios::target': }

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
    'leads':
      source  => 'puppet:///modules/wr/sudoers.d/leads';
    'it':
      source  => 'puppet:///modules/wr/sudoers.d/it';
  }
}
