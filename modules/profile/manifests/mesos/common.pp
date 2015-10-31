#
class profile::mesos::common inherits profile::nis {

  include docker

  # Use postfix to make sure email from cron and sent to root is sent out
  include postfix
  Class['wr::common::repos'] -> Class['postfix']

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
      groups     => ['docker'],
      shell      => '/bin/bash',
      password   => '$5$6F1BpKqFcszWi0n$fC5yUBkPNXHfyL8TOJwdJ1EE8kIzwJnKVrtcFYnpbcA',
      require    => Group [ 'wrlbuild' ];
  }

  # group created by docker package, must be declared here so that wrlbuild
  # can be in docker group
  group {
    'docker':
      ensure  => present,
      require => Class['docker'];
  }

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

  package {
    [ 'openjdk-7-jre-headless','python-setuptools', 'apparmor-utils', 'curl',
      'linux-image-generic-lts-vivid', 'python-protobuf', 'rdfind', 'symlinks']:
      ensure  => present,
      require => Class['wr::common::repos'];
  }

  package {
    'landscape-common':
      ensure => absent;
  }

  Class['wr::common::repos'] -> Class['mesos']
  Package['openjdk-7-jre-headless'] -> File['/usr/lib/libjvm.so'] -> Package['mesos']

  #add internal apt repo of mesosphere packages
  apt::key {
    'wr_mesos':
      key        => '7B189EAFA47D5C008EBC5E11E53FE6207132E47D',
      key_source => "http://${::location}-mirror.wrs.com/mirror/apt/repos.mesosphere.io/ubuntu/dists/trusty/Release.gpg";
  }
  apt::source {
    'mesos':
      location    => "http://${::location}-mirror.wrs.com/mirror/apt/repos.mesosphere.io/ubuntu",
      release     => $::lsbdistcodename,
      repos       => 'main',
      include_src => false;
    'wr-docker':
      location     => "http://${::location}-mirror.wrs.com/mirror/apt/apt.dockerproject.org/repo/",
      release      => "ubuntu-${::lsbdistcodename}",
      repos        => 'main',
      architecture => 'amd64',
      include_src  => false,
      key          => '58118E89F3A912897C070ADBF76221572C52609D',
      key_server   => 'p80.pool.sks-keyservers.net:80';
  }
  Apt::Key['wr_mesos'] -> Apt::Source['mesos'] -> Package['mesos']

  package {
    'docker-engine':
      ensure  => '1.8.3-0~trusty';
  }
  Apt::Source['wr-docker'] -> Package['docker-engine']

  file {
    '/etc/rc.local':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0755',
      source => 'puppet:///modules/wr/docker-rc.local';
  }

  ssh_authorized_key {
    'kscherer_desktop_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('kscherer@yow-kscherer-d1'),
      type   => 'ssh-rsa';
    'kscherer_home_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('kscherer@helix'),
      type   => 'ssh-rsa';
    'kscherer_laptop_wrlbuild':
      ensure => 'present',
      user   => 'wrlbuild',
      key    => hiera('kscherer@yow-kscherer-l1'),
      type   => 'ssh-rsa';
  }
}
