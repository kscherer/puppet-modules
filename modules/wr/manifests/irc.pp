#
class wr::irc inherits wr::mcollective {
  class { 'redhat': }
  -> class { 'ntp':
    servers => $wr::common::ntp_servers,
  }
  -> class { 'puppet':
    puppet_server               => $wr::common::puppet_server,
    puppet_agent_ensure         => 'latest',
    puppet_agent_service_enable => false,
    agent                       => true,
  }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'collectd::client': }
  -> class { 'nagios::target': }

  #enable auto update using cron
  package {
    ['yum-cron', 'bash-completion', 'ircd-hybrid']:
      ensure => installed;
    'yum-updatesd':
      ensure => absent;
  }
}
