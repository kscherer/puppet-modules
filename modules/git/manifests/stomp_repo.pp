class git::stomp_repo {

  $remote = 'git://ala-git.wrs.com/users/kscherer/git-stomp-hooks'
  $local = '/var/lib/puppet/repos/git-stomp-hooks'

  vcsrepo {
    $local:
      ensure   => 'present',
      provider => 'git',
      source   => $remote,
      user     => 'puppet',
      revision => 'master';
  }
}
