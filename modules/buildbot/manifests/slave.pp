
# Class to install buildbot
class buildbot::slave(
  $master     = 'yow-lpgbld-master.wrs.com:9989',
  $slave_name = $::hostname
  )
{
  if $::operatingsystem == 'CentOS' {
    yumrepo {
      'buildbot':
        baseurl  => 'http://yow-mirror.wrs.com/mirror/buildbot',
        descr    => 'YOW Buildbot repo',
        enabled  => 1,
        gpgcheck => 0,
        before   => Package['buildbot-slave'],
        notify   => Exec['yum-reload'];
    }
  }

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
      key    => extlookup('kscherer@yow-kscherer-l1'),
      type   => 'ssh-dss';
    'kscherer_home_buildbot':
      ensure => 'present',
      user   => 'buildbot',
      key    => extlookup('kscherer@helix'),
      type   => 'ssh-rsa';
  }

  File {
    owner  => buildbot,
    group  => buildbot
  }

  $bb_base = '/home/buildbot/build'
  file {
    [$bb_base,"$bb_base/slave"]:
      ensure => directory;
    '/home/buildbot/.bashrc':
      ensure => present,
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/home/buildbot/.aliases':
      ensure => present,
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/home/buildbot/.bash_profile':
      ensure  => present,
      mode    => '0755',
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
    '/home/buildbot/prep.sh':
      ensure => present,
      mode   => '0755',
      source => 'puppet:///modules/buildbot/prep.sh';
    '/home/buildbot/.gitconfig':
      mode    => '0644',
      source  => 'puppet:///modules/nx/gitconfig';
    "${bb_base}/slave/info/admin":
      ensure  => present,
      require => [ File["$bb_base/slave"], Package['buildbot-slave'],
                  Exec['create-buildbot-slave']],
      content => 'Konrad Scherer <Konrad.Scherer@windriver.com>';
    "${bb_base}/slave/info/admin":
      ensure  => present,
      require => [ File["$bb_base/slave"], Package['buildbot-slave'],
                  Exec['create-buildbot-slave']],
      content => "OS: $::operatingsystem\nRelease: $::operatingsystemrelease\n";
  }

  Exec {
    path    => '/bin:/usr/bin:/sbin/',
    cwd     => $bb_base,
    require => User['buildbot'],
    user    => 'buildbot',
    group   => 'buildbot',
  }

  exec {
    'clone_bin_repo':
      command => 'git clone git://yow-git.wrs.com/bin',
      cwd     => '/home/buildbot',
      unless  => 'test -d /home/buildbot/bin';
    'create-buildbot-slave':
      require => [ File["$bb_base/slave"], Package['buildbot-slave'],
                  Exec['clone_bin_repo']],
      command => "buildslave create-slave --umask=022 slave $master $slave_name pass",
      creates => "$bb_base/slave/buildbot.tac";
    'start-buildbot-slave':
      require     => [ File["$bb_base/slave"], Package['buildbot-slave'],
                      Exec['create-buildbot-slave']],
      command     => 'buildslave start slave',
      environment => ['HOME=/home/buildbot'],
      #check if buildbot slave is running by checking for pid
      unless      => 'test -e slave/twistd.pid && test -d /proc/$(cat slave/twistd.pid)';
  }

  #update local wrlinux repo used for reference cloning
  #this could create thundering herd on git servers
  cron {
    'pull_wrlinux':
      command => 'cd /home/buildbot/wrlinux-x; /home/buildbot/bin/wrgit pull &> /dev/null',
      minute  => '0',
      user    => 'buildbot';
    'pull_bin':
      command => 'cd /home/buildbot/bin; /usr/bin/git pull &> /dev/null',
      minute  => '30',
      user    => 'buildbot';
  }
}
