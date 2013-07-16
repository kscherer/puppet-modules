#Setup grok mirror on the mirror
class git::grokmirror::mirror(
  $site = 'git.kernel.org',
  $toplevel = '/var/lib/git/mirror',
  $projectslist_symlinks = 'no',
  $post_update_hook = undef,
  $default_owner = 'Grokmirror',
  $log_level = 'info',
  $include = '*',
  $exclude = undef
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
  }

  #run the command to actually do the mirroring
  cron {
    'grokmirror_pull':
      ensure  => present,
      command => '/git/grokmirror/grok-pull.py --reuse-existing-repos --config /git/repos.conf',
      user    => 'git';
  }
}
