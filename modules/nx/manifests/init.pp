#
class nx {

  # git is a must install
  include git

  # Add anchor resources for containment
  anchor { 'nx::begin': }
  anchor { 'nx::end': }

  # Do builds as an unprivileged user
  group {
    'nxadm':
      ensure => present,
  }

  #Suse does not support MD5 password hash
  if $::operatingsystem =~ /(OpenSuSE|SLED)/ {
    $nxadm_password_hash = '$2a$10$Fmxo9G5eGHoqgn4X4z1IZuMrOOfVVnPgNT24kVQebDZi106w65vR2'
  } else {
    $nxadm_password_hash = '$1$NLcnHXhT$JF7LPuL7Er8lGAxRiS/gc0'
  }

  user {
    'nxadm':
      ensure     => present,
      gid        => 'nxadm',
      managehome => true,
      home       => '/home/nxadm',
      shell      => '/bin/bash',
      password   => $nxadm_password_hash,
      require    => Group [ 'nxadm' ];
  }

  ssh_authorized_key {
    'kscherer_windriver_nxadm':
      ensure => 'absent',
      user   => 'nxadm',
      key    => extlookup('kscherer@yow-kscherer-l1'),
      type   => 'ssh-dss';
    'kscherer_d1_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => hiera('kscherer@yow-kscherer-d1'),
      type   => 'ssh-rsa';
    'kscherer_home_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('kscherer@helix'),
      type   => 'ssh-rsa';
    'jwessel_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('jwessel@splat'),
      type   => 'ssh-rsa';
    'rmacleod_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('rmacleod@fidler'),
      type   => 'ssh-dss';
    'jmacdonald_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('trogdor@burninator'),
      type   => 'ssh-dss';
    'wenzong_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('wfan@pek-wenzong-fan'),
      type   => 'ssh-dss';
    'kai_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('kai@pek-kkang-d1'),
      type   => 'ssh-rsa';
    'jackie_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => extlookup('jhuang0@pek-cc-pb05l.wrs.com'),
      type   => 'ssh-rsa';
    'polk_nxadm':
      ensure => 'present',
      user   => 'nxadm',
      key    => hiera('polk@delos.com'),
      type   => 'ssh-dss';
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
      recurse => true,
      purge   => true;
    '/etc/init.d/nx_instance':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => 'puppet:///modules/nx/nx_instance';
    '/home/nxadm/.gitconfig':
      mode    => '0644',
      source  => 'puppet:///modules/nx/gitconfig';
    ['/home/nxadm/.ssh/', '/home/nxadm/.history']:
      ensure => directory,
      mode   => '0700';
    '/home/nxadm/.ssh/id_dsa.pub':
      ensure => present,
      source => 'puppet:///modules/nx/id_dsa.pub',
      mode   => '0600';
    '/home/nxadm/.ssh/id_dsa':
      ensure => present,
      source => 'puppet:///modules/nx/id_dsa',
      mode   => '0600';
    '/home/nxadm/.ssh/config':
      ensure => present,
      mode   => '0600',
      source => 'puppet:///modules/nx/ssh_config';
    '/etc/facter/facts.d/nx.txt':
      ensure  => present,
      content => 'branch=master';
    #make sure the build dirs are not indexed
    '/etc/updatedb.conf':
      ensure => present,
      source => 'puppet:///modules/nx/updatedb.conf';
    '/home/nxadm/.bashrc':
      ensure => present,
      owner  => 'nxadm',
      group  => 'nxadm',
      mode   => '0755',
      source => 'puppet:///modules/wr/bashrc';
    '/home/nxadm/.aliases':
      ensure => present,
      owner  => 'nxadm',
      group  => 'nxadm',
      mode   => '0755',
      source => 'puppet:///modules/wr/aliases';
    '/home/nxadm/.bash_profile':
      ensure  => present,
      content => 'if [ -f $HOME/.bashrc ]; then source $HOME/.bashrc; fi';
    '/etc/security/limits.d/':
      ensure  => directory,
      owner   => 'root',
      group   => 'root';
    '/etc/security/limits.d/90-nxadm-allow-core.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => 'nxadm soft core unlimited';
    #prevent accidental forkbombs, but builds with high parallelism
    #can generate more than default 1024 limit. So it is increased.
    '/etc/security/limits.d/90-nproc.conf':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => '* soft nproc 5000';
  }

  #
  define nx::script() {
    file {
      $name:
        path    => "/home/nxadm/bin/${name}",
        mode    => '0755',
        source  => "puppet:///modules/nx/${name}",
        require => File['/home/nxadm/bin'];
    }
  }

  nx::script {
    [ 'hostel-fix-config','ice_check.sh','pull-multicore-layer','hostel-make',
      'pull-toolchain.sh','send_stats_to_graphite.sh',
      'sstate-cache-management.sh']:
  }

  case $::hostname {
    /^yow-lpgbuild-*/: { include nx::yow-lpgbuild }
    /^yow-lpgbld-vm*/: { include nx::yow-hostel }
    /^yow-blade*/:     { include nx::yow-blades }
    /^ala-blade*/:     { include nx::ala-blades }
    /^pek-blade*/:     { include nx::pek-blades }
    /^pek-usp*/:       { include nx::pek-usp }
    /^pek-hostel-vm*/: { include nx::pek-hostel }
    /^ala-lpd-test*/:  { include nx::ala-lpd-test }
    'ala-lpd-rcpl':    { include nx::ala-lpd-rcpl }
    default:           { fail("Unsupported nx configuration for ${::hostname}") }
  }

  $sstate_dir = '/home/nxadm/nx/sstate_cache'

  cron {
    #Delete log files older that 10 days
    'clean_nx_logs':
      command => "/usr/bin/find /home/nxadm/nx/${::location}*/log -mtime +10 -exec rm {} \\; &> /dev/null",
      user    => nxadm,
      hour    => 23,
      minute  => 0,
      require => User[ 'nxadm' ];
    #kill any build processes that are older than 2 days (except notxylo)
    'clean_old_nx_processes':
      command => 'ps -U nxadm -o pid,etime,command | grep -v notxylo | awk \'$2~/-/ {if ((0+$2)>3) print $1}\' | xargs -r kill -9',
      user    => nxadm,
      hour    => 20,
      minute  => 0,
      require => User[ 'nxadm' ];
    #Clean out the sstate cache to avoid running out of disk
    'clean_sstate_cache':
      command => "if [ -d ${sstate_dir} ]; then cd /home/nxadm/nx/${::hostname}.1/current_build/layers/oe-core/scripts; ./sstate-cache-management.sh --yes --remove-duplicated --cache-dir=${sstate_dir}; fi",
      user    => nxadm,
      hour    => 20,
      minute  => 0,
      require => User[ 'nxadm' ];
  }

  if $::osfamily == 'RedHat' {
    ensure_resource('package', 'vim-enhanced', {'ensure' => 'installed' })
  }

  #This package causes major io contention
  ensure_resource('package', 'mlocate', {'ensure' => 'absent' })
}
