#
class profile::lava {
  file {
    '/root/lava_backup.sh':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/wr/lava_backup.sh';
  }

  cron {
    'lava_db_backup':
      command => '/root/lava_backup.sh > /dev/null 2>&1',
      user    => 'root',
      hour    => '2',
      minute  => '0',
      require => File['/root/lava_backup.sh'];
  }
}
