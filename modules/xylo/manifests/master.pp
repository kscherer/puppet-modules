#
class xylo::master {

  $base_dir='/stored_builds'

  #clone all the needed repos to run xylo
  exec {
    'clone_xylo_repo':
      command => "git clone git://${::location}-git.wrs.com/git/lpd-ops/xylo",
      user    => 'buildadmin',
      require => File[$base_dir],
      unless  => "test -d ${base_dir}/xylo";
    'clone_bin_repo':
      command => "git clone git://${::location}-git.wrs.com/git/bin binrepo",
      cwd     => "${base_dir}/xylo",
      user    => 'buildadmin',
      require => Exec[ 'clone_bin_repo' ],
      unless  => "test -d ${base_dir}/xylo/binrepo";
    'clone_nodemgr_repo':
      command => 'git clone git://git.wrs.com/git/projects/nodemgr',
      user    => 'buildadmin',
      require => File[$base_dir],
      unless  => "test -d ${base_dir}/nodemgr";
    'clone_fast_core':
      command => 'git clone git://otp-git1.wrs.com/git/local/fast-core-lpd fast-core',
      cwd     => "${base_dir}/nodemgr",
      user    => 'buildadmin',
      require => Exec[ 'clone_nodemgr_repo' ],
      unless  => "test -d ${base_dir}/nodemgr/fast-core";
  }

  # Setup nodermgr
  file {
    "${base_dir}/xylo/nodemgr":
      ensure => link,
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755',
      target => "${base_dir}/nodemgr";
    "${base_dir}/xylo/nodemgr/nodemgrconsts.py":
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755',
      source => 'puppet:///modules/xylo/nodemgrconsts.py';
    "${base_dir}/xylo/nodemgr/nodemgr.ini":
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755',
      source => "puppet:///modules/xylo/${::location}-nodemgr.ini";
  }

  # Setup site config files
  file {
    "${base_dir}/site":
      ensure => directory,
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755';
    "${base_dir}/site/siteconfig":
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755',
      source => 'puppet:///modules/xylo/pek-siteconfig';
    "${base_dir}/site/config.php":
      owner   => 'buildadmin',
      group   => 'buildadmin',
      mode    => '0755',
      content => template('xylo/config.php.erb');
    "${base_dir}/xylo/siteconfig":
      ensure => link,
      target => "${base_dir}/site/siteconfig";
    "${base_dir}/xylo/html/config.php":
      ensure => link,
      target => "${base_dir}/site/config.php";
  }

  #contains newer packages needed for xylo
  redhat::yum_repo {
    'xylo':
      baseurl     => 'http://ala-mirror.wrs.com/mirror/xylo';
  }

  # packages are needed to run xylo script
  package {
    [ 'httpd','cvs','php', 'perl-XML-Simple' ]:
      ensure => installed;
  }

  #make sure latest Twig package is installed
  package {
    'perl-XML-Twig':
      ensure  => latest,
      require => Yumrepo['xylo'];
  }

  # packages are needed to run nodemgr
  package {
    [ 'python26','python-configobj' ]:
      ensure => installed;
  }

  # fix python modules path
  file {
    '/usr/bin/python2.5':
      ensure  => file,
      mode    => '0755',
      content => 'export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.4/site-packages; python26 $@';
  }

  # others
  package {
    'screen':
      ensure => installed;
  }

  # Setup httpd service
  file {
    '/etc/httpd/conf.d/xylo.conf':
      owner  => 'buildadmin',
      group  => 'buildadmin',
      mode   => '0755',
      source => 'puppet:///modules/xylo/xylo.conf';
  }

  service {
    'httpd':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Exec['clone_xylo_repo'];
  }

  # Create builds dir
  file {
    "${base_dir}/builds":
      ensure  => directory,
      owner   => 'buildadmin',
      group   => 'buildadmin',
      mode    => '0775',
      require => File[$base_dir];
  }

  # Setup cron tasks on Xylo master
  cron {
    'build_cleanup':
      environment => 'MAILTO="lpd-eng-infrastructure@windriver.com"',
      command     => '/stored_builds/xylo/scripts/build-cleanup 600 /stored_builds/builds > /stored_builds/cleanup.log 2>&1',
      user        => buildadmin,
      hour        => 4,
      minute      => 0;
    'gen_build_status_page':
      command => 'cd /stored_builds/xylo ; scripts/gen-build-status-table --num=10',
      user    => buildadmin,
      minute  => 30;
  }
}
