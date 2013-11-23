#
class role::provisioner {
  include profile::nis

  cron {
    'delete_foreman_reports':
      ensure  => present,
      user    => 'root',
      hour    => '0',
      minute  => '0',
      command => '/usr/sbin/foreman-rake reports:expire days=1 status=0; /usr/sbin/foreman-rake reports:expire days=7';
  }
}
