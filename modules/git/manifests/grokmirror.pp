#Install and manage grokmirror
class git::grokmirror {
  vcsrepo {
    '/git/grokmirror':
      ensure   => 'latest',
      provider => 'git',
      source   => 'git://github.com/mricon/grokmirror.git',
      user     => 'git',
      revision => 'master';
  }
}
