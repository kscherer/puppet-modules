#
class wr::pek-xenserver inherits wr::mcollective {

  class { 'apt': purge_sources_list => true }
  class { 'debian': }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => $wr::common::puppet_version,
    puppet_agent_service_enable => false,
    agent                       => true,
  }
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
