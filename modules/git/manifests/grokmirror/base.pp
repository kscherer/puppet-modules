#Install and manage grokmirror
class git::grokmirror::base {

  vcsrepo {
    '/git/grokmirror':
      ensure   => 'latest',
      provider => 'git',
      source   => 'git://github.com/mricon/grokmirror.git',
      user     => 'git',
      revision => 'master';
  }
}
