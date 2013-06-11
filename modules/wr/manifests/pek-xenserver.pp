#
class wr::pek-xenserver {

  class { 'apt': purge_sources_list => true }
  class { 'debian': }
  -> class { 'wr::common': }
  -> class { 'wr::mcollective': }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'xen': }

  #make sure mcollective package does not try to install packages until
  #sources have been installed
  Class['debian'] -> Class['mcollective']

  ssh_authorized_key {
    'wenzong':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('wfan@pek-wenzong-fan'),
      type   => 'ssh-dss';
  }

}
