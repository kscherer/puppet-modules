#
class wr::ala-lpd-rcpl {
  class { 'wr::common': }
  -> class { 'redhat::autoupdate': }
  -> class { 'yocto': }
  -> class { 'nx': }
  -> class { 'git::git-daemon': }

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
    ['cgit']:
      ensure => installed;
  }

  mount {
    '/data':
      ensure   => mounted,
      atboot   => true,
      device   => '/dev/mapper/vg-data',
      fstype   => 'ext4',
      options  => 'defaults',
      remounts => true;
  }

  user {
    'git':
      ensure     => present,
      groups     => 'git',
      managehome => true,
      home       => '/home/git',
      shell      => '/bin/bash';
  }

  group {
    'git':
      ensure  => present,
      require => User['git'];
  }

  file {
    '/data/git':
      ensure => directory,
      owner  => 'git',
      group  => 'git';
    '/git':
      ensure => link,
      target => '/data/git';
  }

}
