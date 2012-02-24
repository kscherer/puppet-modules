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
      gid        => 'nxadm',
      managehome => true,
      home       => '/home/nxadm',
      password   => '$1$NLcnHXhT$JF7LPuL7Er8lGAxRiS/gc0',
      require    => Group [ 'nxadm' ];
  }

  File {
    owner   => 'nxadm',
    group   => 'nxadm',
  }

  file {
    '/home/nxadm':
      ensure  => directory,
      mode    => '0755';
    '/home/nxadm/bin':
      ensure  => directory,
      mode    => '0755';
    '/etc/init.d/nx_instance':
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///nx/nx_instance';
    '/home/nxadm/.gitconfig':
      mode    => '0644',
      source  => 'puppet:///nx/gitconfig';
    '/home/nxadm/.ssh/':
      ensure => directory,
      mode   => '0600';
    '/home/nxadm/.ssh/id_dsa.pub':
      ensure => present,
      source => 'puppet:///nx/id_dsa.pub',
      mode   => '0600';
    '/home/nxadm/.ssh/id_dsa':
      ensure => present,
      source => 'puppet:///nx/id_dsa',
      mode   => '0600';
  }

  define nx::script() {
    file {
      $name:
        path    => "/home/nxadm/bin/$name",
        mode    => '0755',
        source  => "puppet:///nx/$name",
        require => File['/home/nxadm/bin'];
    }
  }

  nx::script {
    ['hostel-fix-config','ice_check.sh','pull-multicore-layer','hostel-make']:
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
