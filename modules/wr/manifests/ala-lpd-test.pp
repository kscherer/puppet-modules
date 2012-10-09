#
class wr::ala-lpd-test {
  class { 'wr::mcollective': }
  -> class { 'redhat::autoupdate': }
  -> class { 'git': }
  -> class { 'sudo': }
  -> class { 'yocto': }

  motd::register {
    'ala-lpd-test':
      content =>
      'This machine is reserved for Linux Products automated testing only.';
  }

  sudo::conf {
    'admin':
      source  => 'puppet:///modules/wr/sudoers.d/admin';
  }

  file {
    'e2croncheck':
      ensure => present,
      path   => '/root/e2croncheck',
      mode   => '0755',
      source => 'puppet:///modules/wr/e2croncheck';
    '/data':
      ensure => directory;
    '/data/wr-taf':
      ensure  => directory,
      owner   => 'wr-taf',
      group   => 'users',
      mode    => '0755',
      require => Mount['/data'];
  }

  mount {
    '/data':
      ensure   => mounted,
      atboot   => true,
      device   => '/dev/mapper/vg-data',
      fstype   => 'ext4',
      options  => 'defaults',
      remounts => true,
      require  => File['/data'];
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
