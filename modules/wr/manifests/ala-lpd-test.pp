#
class wr::ala-lpd-test {
  class { 'redhat': }
  -> class { 'redhat::autoupdate': }
  -> class { 'wr::mcollective': }
  -> class { 'git': }
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
  }

  file {
    'e2croncheck':
      ensure => present,
      path   => '/root/e2croncheck',
      mode   => '0755',
      source => 'puppet:///modules/wr/e2croncheck';
    '/data':
      ensure => directory;
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
