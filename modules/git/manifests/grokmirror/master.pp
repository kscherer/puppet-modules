#Setup grok mirror on the master
class git::grokmirror::master(
  $docroot = 'UNSET'
) {
  include git::params
  $docroot_real = $docroot ? {
    'UNSET' => $git::params::docroot,
    default => $docroot,
  }

  include git::grokmirror::base

  #use apache to serve git repo manifest
  include apache

  apache::vhost {
    'grokmirror':
      port    => '80',
      docroot => $docroot_real,
  }

  file {
    "${docroot_real}/grokmirror":
      ensure => directory,
      owner  => 'git',
      group  => 'git';
    "${docroot_real}/manifest.js.gz":
      ensure => link,
      target => '/git/manifest.js.gz';
  }

  $nsca_server=hiera('nsca')
  cron {
    'nsca_external_sync_check':
      command => "PATH=/bin:/sbin:/usr/sbin:/usr/bin /etc/nagios/nsca_wrapper -H ${::fqdn} -S 'External Repo sync check' -N ${nsca_server} -c /etc/nagios/send_nsca.cfg -C /etc/nagios/check_external_log_errors.sh -q",
      user    => 'nagios',
      minute  => '0',
      hour    => '8';
  }
}
