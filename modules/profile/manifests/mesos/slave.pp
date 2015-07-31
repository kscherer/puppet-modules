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

  #Make sure chronos-docker executor is available before slave service is started
  Vcsrepo['/home/wrlbuild/wr-buildscripts'] -> Service['mesos-slave']

  file {
    '/home/wrlbuild/builds':
      ensure => directory,
      owner  => 'wrlbuild',
      group  => 'users',
      mode   => '0775';
    '/etc/init/mesos-master.override':
      ensure  => present,
      content => 'manual';
    '/mnt/docker':
      ensure => directory;
    # make sure that wrlinux update log file can be read by nagios scripts
    '/home/wrlbuild/log/wrlinux_update.log':
      ensure => file,
      owner  => 'wrlbuild',
      group  => 'users',
      mode   => '0644';
  }

  mount {
    '/mnt/docker':
      ensure   => mounted,
      atboot   => true,
      device   => 'tmpfs',
      fstype   => 'tmpfs',
      options  => 'defaults,noatime,mode=1777,nosuid,size=1G',
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
      command => 'cd /home/wrlbuild/wr-buildscripts; /usr/bin/git fetch --quiet --all; /usr/bin/git reset --hard origin/master; ./wrlinux_update.sh >> /home/wrlbuild/log/wrlinux_update.log 2>&1',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => fqdn_rand(60, 'wrlinux_update');
    'cleanup_stopped_containers':
      ensure  => absent,
      command => '/usr/bin/docker rm $(/usr/bin/docker ps -a -q) > /dev/null 2>&1',
      minute  => fqdn_rand(60, 'container cleanup');
    'cleanup_untagged_images':
      command => '/usr/bin/docker rmi $(/usr/bin/docker images --filter dangling=true -q 2>/dev/null}") > /dev/null 2>&1',
      minute  => fqdn_rand(60, 'images cleanup');
    'native_sstate_update':
      command => '/home/wrlbuild/wr-buildscripts/retrieve_native_sstate.sh /home/wrlbuild > /dev/null 2>&1',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => fqdn_rand(60, 'native_sstate_update');
    'kill_hung_builds':
      ensure  => present,
      command => '/home/wrlbuild/wr-buildscripts/kill_hung_tasks.sh >> /home/wrlbuild/log/hung_task.log 2>&1',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => '0';
  }

  exec {
    'setup_memory_cgroup':
      command => '/bin/sed -i \'s/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 cgroup_enable=memory swapaccount=1"/\' /etc/default/grub',
      unless  => 'cat /etc/default/grub | /bin/grep \'GRUB_CMDLINE_LINUX=\' | /bin/grep swapaccount=1',
      notify  => Exec['update-grub'];
  }

  #for integration with existing nx stats and fails repos
  file {
    '/home/wrlbuild/.history':
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
    '/home/wrlbuild/.oe-send-error':
      ensure => present,
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0644',
      source => 'puppet:///modules/wr/send-error-config';
    '/home/wrlbuild/.gitconfig':
      ensure => present,
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0664',
      source => 'puppet:///modules/wr/wrlbuild_gitconfig';
  }

  #post process script uses git send-email
  ensure_resource('package', 'git-email', {'ensure' => 'present' })

  cron {
    'build_postprocess':
      command => 'cd /home/wrlbuild/wr-buildscripts; ./build_postprocess.sh >> /home/wrlbuild/log/postprocess.log',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => [0,15,30,45];
    #Delete log files older that 10 days
    'clean_docker_tmp':
      command => '/usr/bin/find /mnt/docker -mtime +1 -delete &> /dev/null',
      user    => wrlbuild,
      hour    => 23,
      minute  => 0,
      require => User['wrlbuild'];
  }

  #give wrlbuild user sudo access to fixup permission problems
  sudo::conf {
    'wrlbuild':
      source  => 'puppet:///modules/wr/sudoers.d/wrlbuild';
  }

  # check to make sure the wrlinux update script did not fail
  include nagios::nsca::client
  @@nagios_service {
    "check_wrlinux_update_${::hostname}":
      use                 => 'passive-service',
      service_description => 'Wrlinux source update check',
      host_name           => $::fqdn,
      servicegroups       => 'mesos-slaves';
  }

  $nsca_server=hiera('nsca')

  cron {
    'nsca_wrlinux_update_log_check':
      command => "PATH=/bin:/sbin:/usr/sbin:/usr/bin /etc/nagios/nsca_wrapper -H ${::fqdn} -S 'Wrlinux source update check' -N ${nsca_server} -c /etc/nagios/send_nsca.cfg -C /etc/nagios/check_wrlinux_update.sh -q",
      user    => 'nagios',
      hour    => '*',
      minute  => '0';
  }

  ssh_authorized_key {
    'wenzong_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => extlookup('wfan@pek-wenzong-fan'),
      type   => 'ssh-dss';
  }

  include logrotate

  #rotate the grokmirror log file
  logrotate::rule {
    'wraxl':
      path         => '/home/wrlbuild/log/*.log',
      rotate       => 7,
      rotate_every => 'day',
      missingok    => true,
      ifempty      => false,
      su           => true,
      su_owner     => 'wrlbuild',
      su_group     => 'wrlbuild',
      compress     => true;
  }

  # Use cadvisor to expose container stats
  docker::image {
    'google/cadvisor':
      image_tag => 'latest';
  }
  docker::run {
    'cadvisor':
      image   => 'google/cadvisor',
      ports   => ['8080:8080'],
      volumes => ['/:/rootfs:ro', '/var/run:/var/run:rw', '/sys:/sys:ro', '/var/lib/docker/:/var/lib/docker:ro'],
      detach  => true;
  }

  # create an ssh key for wrlbuild and publish it as a fact
  sshkeys::create_ssh_key {'wrlbuild': }
}
