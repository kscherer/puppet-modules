#
class wr::ala-lpd-rcpl {
  class { 'redhat': }
  -> class { 'redhat::autoupdate': }
  -> class { 'wr::mcollective': }
  -> class { 'nrpe': }
  -> class { 'yocto': }
  -> class { 'nx': }
  -> class { 'git::git-daemon': }
  -> class { 'git::cgit': }

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
    'pkennedy_git':
      ensure => 'present',
      user   => 'git',
      key    => extlookup('pkennedy@linux-y9cs.site'),
      type   => 'ssh-dss';
    'wenzong_git':
      ensure => 'present',
      user   => 'git',
      key    => extlookup('wfan@pek-wenzong-fan'),
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

  yumrepo {
    'git':
      enabled  => '1',
      descr    => 'Latest git',
      gpgcheck => '0',
      before   => Package['git'],
      baseurl  => 'http://ala-mirror.wrs.com/mirror/git';
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
    #this recursive link is needed due an assumption in many scripts
    '/data/git/git':
      ensure => link,
      owner  => 'git',
      group  => 'git',
      target => '.';
    '/git':
      ensure => link,
      target => '/data/git';
  }

  #setup local ala-git mirror
  $env='MAILTO=konrad.scherer@windriver.com'

  cron {
    'e2croncheck':
      ensure      => present,
      command     => 'PATH=/bin:/sbin/:/usr/bin /root/e2croncheck vg/data',
      environment => $env,
      user        => root,
      hour        => 22,
      minute      => 0,
      weekday     => 6,
      require     => File['e2croncheck'];
    'mirror-update-5min':
      command     => 'MIRROR=ala-git.wrs.com /git/bin/mirror-update 5mins',
      environment => $env,
      user        => 'git',
      minute      => [ 3,8,13,18,23,28,33,38,43,48,53 ];
    'mirror-update-hourly':
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-update hourly 5mins',
      user    => 'git',
      minute  => 56,
      hour    => ['1-23'];
    'mirror-kernels':
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-kernels',
      user    => 'git',
      minute  => 30;
    'mirror-repositories':
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-repository 5mins hourly',
      user    => 'git',
      minute  => 56,
      hour    => 0,
      weekday => ['1-6'];
    'mirror-truncate':
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-truncate-log',
      user    => 'git',
      minute  => 56,
      hour    => 0,
      weekday => 0;
  }
}
