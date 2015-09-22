class wr::foreman_common {

  include ::debian::foreman

  cron {
    'delete_foreman_reports':
      ensure  => present,
      user    => 'root',
      hour    => '0',
      minute  => '0',
      command => '/usr/sbin/foreman-rake reports:expire days=1 status=0 &> /dev/null; /usr/sbin/foreman-rake reports:expire days=7 &> /dev/null';
  }
}
