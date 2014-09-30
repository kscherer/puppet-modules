#
class profile::mesos::master inherits profile::mesos::common {
  include ::mesos::master
  include docker

  Class['wr::common::repos'] -> Class['docker']

  file {
    '/etc/init/mesos-slave.override':
      ensure  => present,
      content => 'manual';
  }

  #mandatory configuration options for 0.19
  file {
    '/etc/mesos-master/work_dir':
      content => '/var/lib/mesos/';
    '/etc/mesos-master/quorum':
      content => '1';
  }

  #random build coverage scheduler reads yaml config files
  ensure_resource('package', 'python-yaml', {'ensure' => 'installed' })

  file {
    '/home/wrlbuild/log':
      ensure => directory,
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0755';
  }

  cron {
    'use_latest_nx_configs':
      command => 'cd /home/wrlbuild/wr-buildscripts; /usr/bin/git fetch --all; /usr/bin/git reset --hard origin/master; ./process_nx_configs.sh >> /home/wrlbuild/log/process_nx_configs.log',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => fqdn_rand(60, 'process_nx_configs'),
      require => File['/home/wrlbuild/log'];
  }

  #upstart config to manage build scheduler
  file {
    '/etc/init/build_scheduler.conf':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/wr/build_scheduler.conf';
  }

  #This installs python-pip
  include python

  #rq is used by build scheduler to read queues
  wr::pip_userpackage {
    ['rq', 'rq-dashboard']:
      owner => 'wrlbuild';
  }
}
