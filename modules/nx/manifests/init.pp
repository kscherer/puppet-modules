
# Simplify defining files for the buildadmin user
define bafile( $mode = 644, $ensure = file, $path = "", $require = User[ "buildadmin" ], $user = "buildadmin" ) {
  file {
    "$name":
      path => "/home/$user/$path/$name",
      mode => $mode,
      owner => "$user",
      group => "$user",
      source => $ensure ? {
        directory => undef,
        default => "puppet:///modules/nx/$name",
      },
      backup => false,
      ensure => $ensure,
      require => $require;
  }
}

class nx {

  # git is a must install
  package {
    "git-email":
      ensure => present;
  }

  if $operatingsystem == 'Ubuntu' {
    $git_package_name = 'git-core'
  } else {
    $git_package_name = 'git'
  }

  package {
    "$git_package_name":
      ensure => present;
  }

  #require nfs to find mount prebuilts
  case $operatingsystem {
    'Ubuntu' : { $nfs_package_name = 'nfs-common' }
    'OpenSuSE' : { $nfs_package_name = 'nfs-client' }
    'SLED' : {
      if $operatingsystemrelease == '10.2' {
        $nfs_package_name = 'nfs-utils'
      } else {
        $nfs_package_name = 'nfs-client'
      }
    }
    default : { $nfs_package_name = 'nfs-utils' }
  }
  package {
    "$nfs_package_name":
      ensure => present;
  }

  # Do builds as an unprivileged user. Password is not necessary
  group { [ "buildadmin", "build" ] :
    ensure => present
  }
  user { "buildadmin":
    ensure => present,
    gid => "buildadmin",
    managehome => true,
    home => "/home/buildadmin",
    password => '$1$PDUoqtDt$nniOcY0kJCryX8fm.ZEZh/';
  }
  user { "build":
    ensure => present,
    gid => "build",
    managehome => true,
    home => "/home/build",
    groups => [ 'buildadmin' ],
    password => '$1$aoDl3jfP$XkxNIqZ2xh6lHWMLnHMbD1';
  }

  $gitconfig="
[user]
  name = BuildAdmin
  email = buildadmin@windriver.com
[sendemail]
  suppresscc = all
[wrgit]
  username = kscherer
  autoupdate = true\n"

  #create all the files needed to setup nx
  bafile {
    [ 'setupnx.sh', 'runnx.sh', 'ice_check.sh' ]:
      mode => 755;
    [ 'configs', 'log', 'nxrc_files', 'ccache' ]:
      ensure => directory;
    '.ssh':
      mode => 700,
      ensure => directory;
    'hostel-fix-config':
      path => 'nxrc_files',
      mode => 755,
      require => [ User[ 'buildadmin' ], File[ 'nxrc_files' ] ];
  }

  case $hostname {
    /^yow-lpgbuild-*/: { include nx::yow-lpgbuild }
    default:           { include nx::hostel }
  }

  file {
    '/mnt/prebuilt_cache':
      ensure=>directory;
    #give users in buildadmin group read access to buildadmin dir
    '/home/buildadmin':
      mode => 750,
      owner => 'buildadmin',
      group => 'buildadmin',
      ensure=>directory;
    '/home/buildadmin/.gitconfig':
      content => $gitconfig,
      mode => 644,
      owner => 'buildadmin',
      group => 'buildadmin',
      ensure => file;
    '/home/buildadmin/.ssh/config':
      source => 'puppet:///modules/nx/config',
      mode => 600,
      owner => 'buildadmin',
      group => 'buildadmin',
      require => File[ '/home/buildadmin/.ssh' ],
      ensure => file;
    '/home/buildadmin/pull-multicore-layer':
      source => 'puppet:///modules/nx/pull-multicore-layer',
      owner => 'buildadmin',
      group => 'buildadmin',
      ensure => file;
    '/home/buildadmin/.ssh/id_dsa':
      source => 'puppet:///modules/cluster-ssh/id_dsa',
      mode => 600,
      owner => 'buildadmin',
      group => 'buildadmin',
      require => File[ 'id_dsa' ],
      ensure => file;
    '/home/buildadmin/.ssh/id_dsa.pub':
      source => 'puppet:///modules/cluster-ssh/id_dsa.pub',
      mode => 600,
      owner => 'buildadmin',
      group => 'buildadmin',
      require => File[ 'id_dsa.pub' ],
      ensure => file;
    '/home/buildadmin/.ssh/authorized_keys':
      source => 'puppet:///modules/cluster-ssh/authorized_keys',
      mode => 600,
      owner => 'buildadmin',
      group => 'buildadmin',
      require => File[ 'authorized_keys' ],
      ensure => file;
    '/home/buildadmin/.ccache':
      backup => false,
      recurse => true,
      force => true,
      ensure => absent;
    '/opt':
      ensure => directory;
    '/opt/windriver':
      require => File[ '/opt' ],
      ensure => directory;
    '/opt/windriver/wrlinux-x':
      require => File[ '/opt/windriver' ],
      ensure => '/home/buildadmin/wrlinux-x';
    '/usr/bin/wrgit':
      ensure => '/home/buildadmin/bin/wrgit';
    '/usr/bin/hostel-make':
      mode => 755,
      owner => root,
      group => root,
      source => 'puppet:///modules/nx/hostel-make';
    '/etc/facter/facts.d/nx.txt':
      require => File['/etc/facter/facts.d'],
      ensure => present,
      content => 'branch=4.3';
  }

  #make sure the prebuilt cache is mounted
  mount {
    'nfs_prebuilt_cache':
      atboot => true,
      device => 'yow-lpggp1:/yow-lpggp15/prebuilt_cache/',
      name => '/mnt/prebuilt_cache',
      fstype => 'nfs',
      options => 'ro,soft,auto,nolock',
      require => File[ '/mnt/prebuilt_cache' ],
      remounts => false,
      ensure => mounted;
  }

  line {
    'build_maxlogins':
      file => '/etc/security/limits.conf',
      line => 'build hard maxlogins 1';
  }

  #execute the nx setup script, which is very simple
  exec {
    'setup':
      command => '/home/buildadmin/setupnx.sh',
      cwd => '/home/buildadmin/',
      path => '/usr/bin:/usr/sbin:/bin',
      user => 'buildadmin',
      unless => 'test -d /home/buildadmin/notxylo',
      require => File['setupnx.sh']
  }

  #clean out the ccache once a week
  cron {
    'weekly_ccache_clean':
      command => '/bin/rm -rf /home/buildadmin/ccache/* &> /dev/null',
      user => buildadmin,
      hour => 23,
      minute => 0,
      require => User[ 'buildadmin' ];
    'clean_known_hosts':
      command => '/bin/rm /home/buildadmin/.ssh/known_hosts &> /dev/null',
      user => buildadmin,
      hour => 23,
      minute => 0,
      require => User[ 'buildadmin' ];
    'clean_nx_logs':
      command => '/usr/bin/find /home/buildadmin/log -mtime +10 -exec rm {} \; &> /dev/null',
      user => buildadmin,
      hour => 23,
      minute => 0,
      require => User[ 'buildadmin' ];
  }

  #make sure the nx and bin repos are using yow-git
  define git_config_update() {
    exec {
      "git_config_update_$name" :
        path => "/usr/bin:/bin:/sbin:/usr/sbin",
        user => 'buildadmin',
        cwd => "/home/buildadmin/$name",
        command => "git config remote.origin.url git://yow-git/local/kscherer/notxylo",
        onlyif => "grep -q 'paul' .git/config"
    }
  }

  file {
    '/home/buildadmin/notxylo/.git/config':
      group => 'buildadmin',
      owner => 'buildadmin';
  }

  git_config_update { 'notxylo': }
}

class nx::hostel {
  bafile {
    "yow-hostel":
      path => "configs",
      require => File[ "configs" ];
    "yow-hostel.nxrc":
      path => "nxrc_files",
      require => File[ "nxrc_files" ];
  }
  file {
    "/home/buildadmin/nxrc_files/$hostname":
      require => File[ "yow-hostel.nxrc" ],
      ensure => "/home/buildadmin/nxrc_files/yow-hostel.nxrc";
  }
}

class nx::yow-lpgbuild {
  file {
    "/home/buildadmin/nxrc_files/$hostname":
      content => template( "nx/yow-lpgbuild.nxrc" ),
      require => File[ "nxrc_files" ];
    "/home/buildadmin/configs/$hostname":
      source => "puppet:///modules/nx/yow-lpgbuild/$hostname",
      ensure => present,
      require => File[ "configs" ];
  }
}
