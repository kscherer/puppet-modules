# Installs the repo and runs the git_stomp_listener service
class git::stomp_listener {
  include git::stomp_repo

  $script = "${git::stomp_repo::local}/git-stomp-listener.py"

  service {
    'git_stomp_listener':
      ensure     => running,
      start      => "${script} start",
      stop       => "${script} stop",
      status     => "${script} status",
      restart    => "${script} restart",
      hasrestart => true,
      hasstatus  => true,
      enable     => manual,
      provider   => base,
      require    => Vcsrepo[$git::stomp_repo::local];
  }
}
