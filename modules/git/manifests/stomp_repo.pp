class git::stomp_repo {

  $remote = 'git://ala-git.wrs.com/users/kscherer/git-stomp-hooks'
  $local = '/var/lib/puppet/repos/git-stomp-hooks'

  vcsrepo {
    $local:
      ensure   => 'latest',
      provider => 'git',
      source   => $remote,
      user     => 'puppet',
      revision => 'master';
  }

  # exec {
  #   'add_remote_master':
  #     command => "git remote add --mirror=fetch master $remote",
  #     unless  => 'git remote show master',
  #     require => Vcsrepo[$local],
  #     cwd     => $local,
  #     user    => 'puppet';
  # }
}
