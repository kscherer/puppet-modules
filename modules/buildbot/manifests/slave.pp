
# Class to install buildbot
class buildbot::slave(
  $master     = 'yow-lpgbld-master.wrs.com:9989',
  $slave_name = $::hostname
  ) {
  package {
    'buildbot-slave':
      ensure  => latest;
  }

  user {
    'buildbot':
      ensure     => present,
      managehome => true,
      password   => '$6$Mog25DQbOHdtiE6u$NSKTsfHKy6C1eX.1JVtZC/WaTw.2KflQpfYvM7SzqzAR50Wv/4.ELsnC7lUhkjxSs0et6aqHIqb2MOwmt39JO0';
  }

  group {
    'buildbot':
  }

  ssh_authorized_key {
    'kscherer_windriver_buildbot':
      ensure => 'present',
      user   => 'buildbot',
      key    => $wr::common::kscherer_windriver_pubkey,
      type   => 'ssh-dss';
    'kscherer_home_buildbot':
      ensure => 'present',
      user   => 'buildbot',
      key    => $wr::common::kscherer_home_pubkey,
      type   => 'ssh-rsa';
  }

  $bb_base = '/home/buildbot/build'
  file {
    [$bb_base,"$bb_base/slave"]:
      ensure => directory,
      owner  => buildbot,
      group  => buildbot;
    '/home/buildbot/.bashrc':
      ensure => present,
      owner  => 'buildbot',
      group  => 'buildbot',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/home/buildbot/.aliases':
      ensure => present,
      owner  => 'buildbot',
      group  => 'buildbot',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/home/buildbot/.bash_profile':
      ensure  => present,
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }

  exec {
    'create-buildbot-slave':
      require => [ File["$bb_base/slave"], Package['buildbot-slave']],
      command => "buildslave create-slave slave $master $slave_name pass",
      path    => '/bin:/usr/bin:/sbin/',
      cwd     => $bb_base,
      user    => 'buildbot',
      group   => 'buildbot',
      creates => '$bb_base/slave/buildbot.tac';
    'start-buildbot-slave':
      require => [ File["$bb_base/slave"],
                  Package['buildbot-slave'], Exec['create-buildbot-slave']],
      command => 'buildslave start slave',
      path    => '/bin:/usr/bin:/sbin/',
      cwd     => $bb_base,
      user    => 'buildbot',
      group   => 'buildbot',
      #check if buildbot slave is running by checking for pid
      unless  => 'test ! -e slave/twistd.pid || test ! -d /proc/$(cat slave/twistd.pid)';
  }
}
