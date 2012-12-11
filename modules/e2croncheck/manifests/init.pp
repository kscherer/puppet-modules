#
class e2croncheck {

  #this script creates an lvm snapshot of an online disk and runs fsck on it.
  #If there are errors then they will be reported
  file {
    'e2croncheck':
      ensure => present,
      path   => '/root/e2croncheck',
      mode   => '0755',
      source => 'puppet:///modules/e2croncheck/e2croncheck';
  }

  #Run the disk check weekly
  cron {
    'e2croncheck':
      ensure      => present,
      command     => 'PATH=/bin:/sbin/:/usr/bin /root/e2croncheck vg/data',
      environment => 'MAILTO=konrad.scherer@windriver.com',
      user        => root,
      hour        => 22,
      minute      => 0,
      weekday     => 6,
      require     => File['e2croncheck'];
  }
}
