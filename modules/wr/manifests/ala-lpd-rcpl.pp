#
class wr::ala-lpd-rcpl {
  include profile::nis

  include git::service
  include git::cgit
  include git::grokmirror::mirror

  include e2croncheck

  ssh_authorized_key {
    'jwessel_root':
      ensure => 'absent',
      user   => 'root',
      key    => extlookup('jwessel@splat'),
      type   => 'ssh-rsa';
    'pkennedy_root':
      ensure => 'absent',
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

  mount {
    '/data':
      ensure   => mounted,
      atboot   => true,
      device   => '/dev/mapper/vg-data',
      fstype   => 'ext4',
      options  => 'defaults',
      remounts => true;
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
    'mirror-update-5min':
      ensure      => absent,
      command     => 'MIRROR=ala-git.wrs.com /git/bin/mirror-update 5mins',
      environment => $env,
      user        => 'git',
      minute      => [ 3,8,13,18,23,28,33,38,43,48,53 ];
    'mirror-update-hourly':
      ensure  => absent,
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-update hourly 5mins',
      user    => 'git',
      minute  => 56,
      hour    => ['1-23'];
    'mirror-repositories':
      ensure  => absent,
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-repository 5mins hourly',
      user    => 'git',
      minute  => 56,
      hour    => 0,
      weekday => ['1-6'];
    'mirror-truncate':
      ensure  => absent,
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-truncate-log',
      user    => 'git',
      minute  => 56,
      hour    => 0,
      weekday => 0;
  }

  sudo::conf {
    'rcpl':
      source  => 'puppet:///modules/wr/sudoers.d/rcpl';
  }

  include docker
}
