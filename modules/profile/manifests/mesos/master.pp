#
class profile::mesos::master inherits profile::mesos::common {
  include ::mesos::master
  include docker

  file {
    '/etc/init/mesos-slave.override':
      ensure  => present,
      content => 'manual';
  }

  #random build coverage scheduler reads yaml config files
  ensure_resource('package', 'python-yaml', {'ensure' => 'installed' })

  cron {
    'wrbuildscripts_update':
      command => 'cd /home/wrlbuild/wr-buildscripts; /usr/bin/git fetch --quiet --all; /usr/bin/git reset --hard origin/master > /dev/null 2>&1',
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
  Class['wr::common::repos'] -> Class['python']

  #rq is used by build scheduler to read queues
  wr::pip_userpackage {
    'rq':
      owner => 'wrlbuild';
  }

  # install mesos.native and mesos.interface eggs
  # required by the random_config_scheduler which is written in python
  # Slaves use the docker containerizer which is shipped with mesos and no
  # python is required
  $mesos_egg = 'mesos-0.24.1-py2.7-linux-x86_64.egg'
  $mesos_interface_egg = 'mesos.interface-0.24.1-py2.7.egg'

  include wget
  wget::fetch {
    $mesos_egg:
      source      => "http://${::location}-mirror.wrs.com/mirror/mesos/${mesos_egg}",
      destination => "/root/${mesos_egg}";
    $mesos_interface_egg:
      source      => "http://${::location}-mirror.wrs.com/mirror/mesos/${mesos_interface_egg}",
      destination => "/root/${mesos_interface_egg}",
  }

  exec {
    'install_mesos_egg':
      command => "/usr/bin/easy_install /root/${mesos_egg}",
      unless  => "/usr/bin/test -e /usr/local/lib/python2.7/dist-packages/${mesos_egg}",
      require => [ Package['python-setuptools'], Wget::Fetch[$mesos_egg]];
    'install_mesos_interface_egg':
      command => "/usr/bin/easy_install /root/${mesos_interface_egg}",
      unless  => "/usr/bin/test -e /usr/local/lib/python2.7/dist-packages/${mesos_interface_egg}",
      require => [ Package['python-setuptools'], Wget::Fetch[$mesos_interface_egg]];
  }

  ::consul::service {
    'mesos-master':
      service_name => 'mesos-master',
      port         => 5050,
      tags         => ['wraxl'],
      checks       => [
        {
        id       => 'health',
        name     => 'mesos-master-health',
        http     => "http://${::hostname}:5050/health",
        interval => '10s',
        timeout  => '1s'
        }
      ]
  }

  include ::consul_template
  file {
    '/etc/mesos_agent_whitelist':
      ensure => present,
      owner  => 'consul-template',
      group  => 'consul-template',
      mode   => '0666';
  }
  consul_template::watch {
    'mesos_agent_whitelist':
      template    => 'wr/mesos_agent_whitelist.ctmpl.erb',
      destination => '/etc/mesos_agent_whitelist',
      command     => true;
  }
}
