#
class wr::ala-lpd-test {
  class { 'wr::mcollective': }
  -> class { 'redhat::autoupdate': }
  -> class { 'yocto': }

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
  }
}
