#
class profile::mesos::slave inherits profile::mesos::common {
  include ::mesos::slave
  include docker
  Class['wr::common::repos'] -> Class['docker']

  #Use collectd to monitor system utilization
  include collectd
  Class['wr::common::repos'] -> Class['collectd']

  docker::image {
    [ 'ala-lpd-mesos.wrs.com:5000/centos5_32', 'ala-lpd-mesos.wrs.com:5000/centos5_64',
      'ala-lpd-mesos.wrs.com:5000/centos6_32', 'ala-lpd-mesos.wrs.com:5000/centos6_64']:
      image_tag => 'wrl',
      require   => Class['docker'];
  }

  #The mesos package can start the mesos master so make sure it is
  #not running on slaves
  service {
    'mesos-master':
      ensure => stopped;
  }
  Package['mesos']->Service['mesos-master']

  # Do builds as an unprivileged user which matches uid of user in docker
  group {
    'wrlbuild':
      ensure => present,
  }

  user {
    'wrlbuild':
      ensure     => present,
      gid        => 'wrlbuild',
      uid        => 1000,
      managehome => true,
      home       => '/home/wrlbuild',
      shell      => '/bin/bash',
      password   => '$5$6F1BpKqFcszWi0n$fC5yUBkPNXHfyL8TOJwdJ1EE8kIzwJnKVrtcFYnpbcA',
      require    => Group [ 'wrlbuild' ];
  }

  #turn off locate package which scans filesystem and use a lot of IO
  ensure_resource('package', 'mlocate', {'ensure' => 'absent' })

  vcsrepo {
    '/home/wrlbuild/wr-buildscripts':
      ensure   => 'present',
      provider => 'git',
      source   => 'git://ala-git.wrs.com/lpd-ops/wr-buildscripts.git',
      user     => 'wrlbuild',
      revision => 'master';
  }

  file {
    ['/home/wrlbuild/log','/home/wrlbuild/builds']:
      ensure => directory,
      owner  => 'wrlbuild',
      group  => 'users',
      mode   => '0775';
    '/etc/init/mesos-master.override':
      ensure  => present,
      content => 'manual';
    '/mnt/docker':
      ensure => directory;
  }

  mount {
    '/mnt/docker':
      ensure   => mounted,
      atboot   => true,
      device   => 'tmpfs',
      fstype   => 'tmpfs',
      options  => 'defaults,noatime,mode=1777,nosuid,noexec,size=1G',
      require  => File['/mnt/docker'],
      remounts => true;
  }

  cron {
    'wrlinux_update':
      command => 'cd /home/wrlbuild/wr-buildscripts; /usr/bin/git fetch --all; /usr/bin/git reset --hard origin/master; ./wrlinux_update.sh > /home/wrlbuild/log/wrlinux_update.log',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => fqdn_rand(60, 'wrlinux_update');
    'cleanup_stopped_containers':
      command => '/usr/bin/docker rm $(/usr/bin/docker ps -a -q) > /dev/null 2>&1',
      minute  => fqdn_rand(60, 'container cleanup');
    'cleanup_untagged_images':
      command => '/usr/bin/docker rmi $(/usr/bin/docker images | /bin/grep "^<none>" | /usr/bin/awk "{print \$3}") > /dev/null 2>&1',
      minute  => fqdn_rand(60, 'images cleanup');
  }

  exec {
    'setup_memory_cgroup':
      command => '/bin/sed -i \'s/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 cgroup_enable=memory swapaccount=1"/\' /etc/default/grub',
      unless  => 'cat /etc/default/grub | /bin/grep \'GRUB_CMDLINE_LINUX=\' | /bin/grep swapaccount=1',
      notify  => Exec['update-grub'];
  }
}
