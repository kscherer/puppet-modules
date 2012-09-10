#
class wr::ala-lpd-rcpl {
  class { 'wr::common': }
  -> class { 'redhat::autoupdate': }
  -> class { 'yocto': }
  -> class { 'nx': }
  -> class { 'git::git-daemon': }

  ssh_authorized_key {
    'jwessel_root':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('jwessel@splat'),
      type   => 'ssh-rsa';
    'pkennedy_root':
      ensure => 'present',
      user   => 'root',
      key    => extlookup('pkennedy@linux-y9cs.site'),
      type   => 'ssh-dss';
  }

  file {
    'e2croncheck':
      ensure => present,
      path   => '/root/e2croncheck',
      mode   => '0755',
      source => 'puppet:///modules/wr/e2croncheck';
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
    '/data/git/rcpl':
      ensure => directory,
      owner  => 'git',
      group  => 'git';
    '/git':
      ensure => link,
      target => '/data/git';
  }

  #setup local ala-git mirror
  $env="MAILTO='konrad.scherer@windriver.com'
PATH=/git/bin:/usr/local/bin:/usr/bin:/bin
MIRROR=ala-git.wrs.com"

  cron {
    'e2croncheck':
      ensure      => present,
      command     => '/root/e2croncheck vg/git',
      environment => $env,
      user        => root,
      hour        => 22,
      minute      => 0,
      weekday     => 6,
      require     => File['e2croncheck'];
    'mirror-update-5min':
      command => 'mirror-update 5mins',
      user    => 'git',
      minute  => [ 3,8,13,18,23,28,33,38,43,48,53 ];
    'mirror-update-hourly':
      command => 'mirror-update hourly 5mins',
      user    => 'git',
      minute  => 56,
      hour    => ['1-23'];
    'mirror-kernels':
      command => 'mirror-kernels',
      user    => 'git',
      minute  => 30;
    'mirror-repositories':
      command => 'mirror-repository 5mins hourly',
      user    => 'git',
      minute  => 56,
      hour    => 0,
      weekday => ['1-6'];
    'mirror-truncate':
      command => 'mirror-truncate-log',
      user    => 'git',
      minute  => 56,
      hour    => 0,
      weekday => 0;
  }
}
