#Create the repo used to keep puppet environments up to date
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

  realize( Redhat::Yum_repo['librarian-puppet'] )
  package {
    'rubygem-librarian-puppet':
      ensure => latest;
  }
}
