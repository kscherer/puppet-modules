#Setup grok mirror on the mirror
class git::grokmirror::mirror(
  $site = 'git.kernel.org',
  $toplevel = '/var/lib/git/mirror',
  $projectslist_symlinks = 'no',
  $post_update_hook = '',
  $default_owner = 'Grokmirror',
  $loglevel = 'info',
  $include = '*',
  $exclude = ''
) {

  include git::grokmirror::base

  file {
    "${toplevel}/log":
      ensure => directory,
      owner  => 'git',
      group  => 'git',
      before => Grokmirror_repos_config["${site}/log"];
  }

  grokmirror_repos_config {
    "${site}/site":
      value   => "git://${site}";
    "${site}/manifest":
      value => "http://${site}/grokmirror/manifest.js.gz";
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
      value   => $loglevel;
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
