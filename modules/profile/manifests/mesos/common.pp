#
class profile::mesos::common inherits profile::nis {

  include ::profile::docker

  # Use postfix to make sure email from cron and sent to root is sent out
  include postfix
  Class['wr::common::repos'] -> Class['postfix']

  include ::profile::mesos::wrlbuild

  #turn off locate package which scans filesystem and use a lot of IO
  ensure_resource('package', 'mlocate', {'ensure' => 'absent' })

  vcsrepo {
    '/home/wrlbuild/wr-buildscripts':
      ensure   => 'present',
      provider => 'git',
      source   => 'git://ala-git.wrs.com/lpd-ops/wr-buildscripts.git',
      user     => 'wrlbuild',
      revision => 'master',
      require  => User['wrlbuild'];
  }

  cron {
    'use_latest_nx_configs':
      command => 'cd /home/wrlbuild/wr-buildscripts; ./process_nx_configs.sh >> /home/wrlbuild/log/process_nx_configs.log',
      user    => 'wrlbuild',
      hour    => '*',
      minute  => fqdn_rand(60, 'process_nx_configs'),
      require => File['/home/wrlbuild/log'];
  }

  file {
    '/usr/lib/libjvm.so':
      ensure => link,
      target => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/libjvm.so';
    '/home/wrlbuild/log':
      ensure => directory,
      owner  => 'wrlbuild',
      group  => 'wrlbuild',
      mode   => '0755';
  }

  ensure_packages( ['openjdk-7-jre-headless','python-setuptools',
                    'apparmor-utils', 'curl'] )

  package {
    'landscape-common':
      ensure => absent;
  }

  Class['wr::common::repos'] -> Class['mesos']
  Package['openjdk-7-jre-headless'] -> File['/usr/lib/libjvm.so'] -> Package['mesos']

  #add internal apt repo of mesosphere packages
  apt::source {
    'mesos':
      location    => "http://${::location}-mirror.wrs.com/mirror/apt/repos.mesosphere.io/ubuntu",
      release     => $::lsbdistcodename,
      repos       => 'main',
      architecture => 'amd64',
      include_src => false,
      key         => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
      key_server  => 'keyserver.ubuntu.com';
  }
  Apt::Source['mesos'] -> Package['mesos']

  file {
    '/etc/rc.local':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0755',
      source => 'puppet:///modules/wr/docker-rc.local';
  }
}
