#
class nx {

  # git is a must install
  include git

  # Add anchor resources for containment
  anchor { 'nx::begin': }
  anchor { 'nx::end': }

  #make sure git is installed before this class starts to create repos
  Class['git'] -> Anchor['nx::begin']

  # Do builds as an unprivileged user
  group {
    'nxadm':
      ensure => present,
  }

  user {
    'nxadm':
      ensure     => present,
      gid        => 'nxadmin',
      managehome => true,
      home       => '/home/nxadm',
      password   => '$1$NLcnHXhT$JF7LPuL7Er8lGAxRiS/gc0',
      require    => Group [ 'nxadm' ];
  }

  File {
    user    => 'nxadm',
    group   => 'nxadm',
    require => User['nxadm'],
  }

  file {
    '/home/nxadm':
      ensure  => directory,
      mode    => '0755';
    '/home/nxadm/bin':
      ensure  => directory,
      mode    => '0755';
    ['hostel-fix-config','ice_check.sh','pull-multicore-layer','hostel-make']:
      path    => "/home/nxadm/bin/$name",
      mode    => '0755',
      source  => "puppet:///nx/$name",
      require => File['/home/nxadm/bin'];
    '/etc/init.d/nx_instance':
      user    => root,
      group   => root,
      source  => "puppet:///nx/$name";
  }

  case $::hostname {
    /^yow-lpgbuild-*/: { include nx::yow-lpgbuild }
    /^yow-lpgbld-vm*/: { include nx::yow-hostel }
    /^yow-blade*/:     { include nx::yow-blades }
    default:           { fail("Unsupported nx configuration for $::hostname") }
  }

  cron {
    'clean_nx_logs':
      command => '/usr/bin/find /home/nxadm/nx/yow*/log -mtime +10 -exec rm {} \; &> /dev/null',
      user    => nxadm,
      hour    => 23,
      minute  => 0,
      require => User[ 'nxadm' ];
  }
}
