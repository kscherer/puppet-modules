#
class profile::mesos::common inherits profile::nis {

  include docker
  Class['wr::common::repos'] -> Class['docker']

  #Use collectd to monitor system utilization
  include collectd
  Class['wr::common::repos'] -> Class['collectd']

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

  file {
    '/usr/lib/libjvm.so':
      ensure => link,
      target => '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/libjvm.so';
  }

  package {
    ['openjdk-7-jre-headless','python-setuptools', 'apparmor-utils', 'curl']:
      ensure  => present,
      require => Class['wr::common::repos'];
  }

  Class['wr::common::repos'] -> Class['mesos']
  Package['openjdk-7-jre-headless'] -> File['/usr/lib/libjvm.so'] -> Package['mesos']

  #add internal apt repo of mesosphere packages
  apt::key {
    'wr_mesos':
      key        => '624C1ADB',
      key_source => 'http://yow-mirror.wrs.com/mirror/mesos/mesos.gpg',
  }
  apt::source {
    'mesos':
      location    => 'http://yow-mirror.wrs.com/mirror/mesos',
      release     => $::lsbdistcodename,
      repos       => 'main',
      include_src => false,
      require     => Apt::Key['wr_mesos'];
  }
  Apt::Source['mesos'] -> Package['mesos']

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

  file {
    '/etc/rc.local':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0755',
      source => 'puppet:///modules/wr/docker-rc.local';
  }
}
