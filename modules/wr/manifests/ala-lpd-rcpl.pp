#
class wr::ala-lpd-rcpl {
  class { 'wr::common': }

  file {
    'e2croncheck':
      ensure => present,
      path   => '/root/e2croncheck',
      mode   => '0755',
      source => 'puppet:///modules/wr/e2croncheck';
  }

  cron {
    'e2croncheck':
      ensure   => present,
      command  => '/root/e2croncheck vg/git >/dev/null',
      user     => root,
      hour     => 22,
      minute   => 0,
      weekday  => 6,
      require  => File['e2croncheck'];
  }

  package {
    ['git','git-daemon','cgit']:
      ensure => installed;
  }

  mount {
    '/git':
      ensure   => mounted,
      atboot   => true,
      device   => '/dev/mapper/vg-git',
      fstype   => 'ext4',
      remounts => true;
  }
}
