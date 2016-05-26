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
      mode   => '0644';
    '/opt/consul-template':
      ensure => directory;
  }
  consul_template::watch {
    'mesos_agent_whitelist':
      template    => 'wr/mesos_agent_whitelist.ctmpl.erb',
      destination => '/tmp/mesos_agent_whitelist',
      command     => 'sed \'/^$/d\' /tmp/mesos_agent_whitelist | sort -V > /etc/mesos_agent_whitelist';
  }
}
