$extlookup_datadir = '/puppet/extdata/'
$extlookup_precedence = [ 'common']

node default {

  class { 'redhat': }
  -> class {
    'wr::mcollective':
      client       => true,
      registration => false,
  }
  -> class { 'ntp':
    servers    => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class{ 'collectd': }

  #vagrant uses puppet apply which needs hiera packages installed
  Class['redhat'] -> package{ 'hiera': ensure => installed; }
}
