#Setup grok mirror on the mirror
class git::grokmirror::mirror(
  $site = 'git.kernel.org',
  $toplevel = '/var/lib/git/mirror',
  $projectslist_symlinks = 'no',
  $post_update_hook = undef,
  $default_owner = 'Grokmirror',
  $log_level = 'info',
  $include = '*',
  $exclude = undef,
  $pull_threads = '5'
) {

  include git::grokmirror::base

  file {
    "${toplevel}/log":
      ensure => directory,
      owner  => 'git',
      group  => 'git',
      before => Grokmirror_repos_config["${site}/log"];
  }

  #Clean unused entries from grokmirror config repo
  resources {
    'grokmirror_repos_config':
      purge => true;
  }

  #Create the entries for the grokmirror config file
  grokmirror_repos_config {
    "${site}/site":
      value   => "git://${site}";
    "${site}/manifest":
      value => "http://${site}/manifest.js.gz";
    "${site}/toplevel":
      value   => $toplevel;
    "${site}/mymanifest":
      value => "${toplevel}/manifest.js.gz";
    "${site}/projectslist":
      value => "${toplevel}/projects.list";
    "${site}/projectslist_trimtop":
      value => $toplevel;
    "${site}/projectslist_symlinks":
      value   => $projectslist_symlinks;
    "${site}/post_update_hook":
      value   => $post_update_hook;
    "${site}/default_owner":
      value   => $default_owner;
    "${site}/log":
      value   => "${toplevel}/log/${site}.log";
    "${site}/loglevel":
      value   => $log_level;
    "${site}/lock":
      value   => "${toplevel}/${site}.lock";
    "${site}/include":
      value   => $include;
    "${site}/exclude":
      value   => $exclude;
    "${site}/pull_threads":
      value   => $pull_threads;
  }

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease == '5' {
    $python = '/usr/bin/python26'
  } else {
    $python = 'python'
  }

  #run the command to actually do the mirroring
  cron {
    'grokmirror_pull':
      ensure  => present,
      command => "PYTHONPATH=/git/grokmirror ${python} /git/grokmirror/grokmirror/pull.py --config /git/repos.conf > /dev/null 2>&1",
      user    => 'git';
    'mirror-kernels':
      command => 'MIRROR=ala-git.wrs.com /git/bin/mirror-kernels',
      user    => 'git',
      minute  => 30;
    'force_grok_pull':
      ensure  => present,
      command => "sleep 15; PYTHONPATH=/git/grokmirror ${python} /git/grokmirror/grokmirror/pull.py --config /git/repos.conf --force > /dev/null 2>&1",
      user    => 'git',
      minute  => fqdn_rand(60);
  }

  include logrotate

  #rotate the grokmirror log file
  logrotate::rule {
    'grokmirror':
      path         => "${toplevel}/log/${site}.log",
      rotate       => 7,
      rotate_every => 'day',
      missingok    => true,
      ifempty      => false,
      dateext      => true,
      compress     => true;
    'git_cron_log':
      path         => "${toplevel}/cron-kernels.log",
      rotate       => 7,
      rotate_every => 'day',
      olddir       => "${toplevel}/log",
      missingok    => true,
      ifempty      => false,
      dateext      => true,
      compress     => true;
  }

  #make a local non bare clone of the wr-hooks repo to get hook
  #management scripts
  vcsrepo {
    '/git/wr-hooks.git':
      ensure   => bare,
      provider => git,
      source   => 'git://ala-git/wr-hooks.git',
      user     => 'git';
    '/git/wr-hooks':
      ensure   => latest,
      provider => git,
      source   => "git://${::fqdn}/wr-hooks.git",
      user     => 'git',
      revision => 'master',
      require  => Vcsrepo['/git/wr-hooks.git'];
  }
}
