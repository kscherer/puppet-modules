#
class wr::irc {
  class { "wr::${::location}_dns": }
  -> class { 'redhat': }
  -> class { 'wr::mcollective': }
  -> class { 'puppet': }
  -> class { 'nrpe': }
  -> class { 'nis': }
  -> class { 'collectd::disable': }
  -> class { 'nagios::target': }

  #enable auto update using cron
  package {
    ['yum-cron', 'bash-completion', 'ircd-hybrid']:
      ensure => installed;
    'yum-updatesd':
      ensure => absent;
  }

  $operators = {
    polk     => { user => 'polk@*', password => '$1$eJKPOkVT$H.rKsMSbJvSuDD6xgh2V70' },
    jrw      => { user => 'jrwessel@*', password => '$1$o.VeV/A/$1sfUSAcxp1HHQYgqRm0Av0' },
    jch      => { user => '*', password => '$1$Zr9XRyXP$pg1b5LR1vHG1/Ztqz720a.' },
    wenzong  => { user => '*', password => '$1$orTTJ7Sl$sS1IaP3l5/0Zjz/ezi3XJ1' },
  }

  file {
    'ircd.conf':
      ensure  => file,
      path    => '/etc/ircd/ircd.conf',
      owner   => 'ircd',
      group   => 'ircd',
      mode    => '0640',
      notify  => Service['ircd'],
      content => template('wr/ircd.conf.erb');
    'ircd.motd':
      ensure  => file,
      path    => '/etc/ircd/ircd.motd',
      owner   => 'ircd',
      group   => 'ircd',
      mode    => '0640',
      notify  => Service['ircd'],
      content => template('wr/ircd.motd.erb');
    '/usr/lib64/ircd/':
      ensure => directory;
    '/usr/lib64/ircd/modules/':
      ensure => directory;
    'm_opme.so':
      ensure => file,
      path   => '/usr/lib64/ircd/modules/m_opme.so',
      mode   => '0755',
      source => 'puppet:///modules/wr/ircd/m_opme.so';
  }

  service {
    'ircd':
      ensure  => running,
      enable  => true,
      restart => '/etc/init.d/ircd reload',
      require => [File['ircd.conf'],File['ircd.motd'],File['m_opme.so']];
  }

  include motd
  motd::register{
    'irc':
      content => 'This machine is reserved for the internal Wind River IRC network.';
  }

}
