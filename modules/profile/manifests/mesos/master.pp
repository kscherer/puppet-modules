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

  #random build coverage scheduler reads yaml config files
  ensure_resource('package', 'python-yaml', {'ensure' => 'installed' })

  cron {
    'wrbuildscripts_update':
      command => 'cd /home/wrlbuild/wr-buildscripts; /usr/bin/git fetch --all; /usr/bin/git reset --hard origin/master > /dev/null 2>&1',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => '*/15';
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
    'rq':
      owner => 'wrlbuild';
  }
}
