#
class role {
  include profile::base
}

#
class role::provisioner {
  include profile::nis

  cron {
    'delete_foreman_reports':
      ensure  => present,
      user    => 'root',
      hour    => '0',
      command => 'foreman-rake reports:expire days=1 status=0; foreman-rake reports:expire days=7';
  }
}
