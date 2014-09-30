#
class profile::mesos::slave inherits profile::mesos::common {
  include ::mesos::slave

  #The mesos package can start the mesos master so make sure it is
  #not running on slaves
  service {
    'mesos-master':
      ensure => stopped;
  }
  Package['mesos']->Service['mesos-master']

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
    '/tmp':
      ensure   => mounted,
      atboot   => true,
      device   => 'tmpfs',
      fstype   => 'tmpfs',
      options  => 'defaults,noatime,mode=1777,nosuid,noexec',
      remounts => true;
    '/':
      ensure   => present,
      atboot   => true,
      device   => '/dev/sda1',
      fstype   => 'ext4',
      options  => 'defaults,noatime,errors=remount-ro';
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

  #Use hosts file as substitute for geographically aware DNS
  $registry_ip = $::location ? {
    'yow'   => '128.224.194.16', #yow-lpd-provision
    default => '147.11.106.56' #ala-lpd-mesos
  }

  host {
    'wr-docker-registry':
      ensure       => present,
      ip           => $registry_ip,
      host_aliases => 'wr-docker-registry.wrs.com';
  }

  #Do not use external isolation
  file {
    '/etc/mesos-slave/containerizer_path':
      ensure => absent;
    '/etc/mesos-slave/isolation':
      ensure => absent;
  }

  #for integration with existing nx stats and fails repos
  file {
    ['/home/wrlbuild/.ssh/', '/home/wrlbuild/.history']:
      ensure => directory,
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0700';
    '/home/wrlbuild/.ssh/id_dsa.pub':
      ensure => present,
      source => 'puppet:///modules/nx/id_dsa.pub',
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0600';
    '/home/wrlbuild/.ssh/id_dsa':
      ensure => present,
      source => 'puppet:///modules/nx/id_dsa',
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0600';
    '/home/wrlbuild/.ssh/config':
      ensure => present,
      mode   => '0600',
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      source => 'puppet:///modules/nx/ssh_config';
    '/home/wrlbuild/.bashrc':
      ensure => present,
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/home/wrlbuild/.aliases':
      ensure => present,
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/home/wrlbuild/.bash_profile':
      ensure  => present,
      owner   => 'wrlbuild',
      group   => 'wrlbuild',
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
  }

  #post process script uses git send-email
  ensure_resource('package', 'git-email', {'ensure' => 'present' })

  cron {
    'build_postprocess':
      command => 'cd /home/wrlbuild/wr-buildscripts; ./build_postprocess.sh > /home/wrlbuild/log/postprocess.log',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => [0,15,30,45];
  }
}
