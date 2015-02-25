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

  package {
    ['ruby193', 'ruby193-ruby-devel', 'gcc']:
      ensure => installed;
  }

  $ruby193='/opt/rh/ruby193/root'
  exec {
    'librarian-puppet-install':
      command     => "${ruby193}/usr/bin/gem install librarian-puppet",
      environment => ["LD_LIBRARY_PATH=${ruby193}/usr/lib64"],
      unless      => "${ruby193}/usr/bin/gem list --local -i librarian-puppet",
      require     => [Package['ruby193'], Package['ruby193-ruby-devel']];
  }
}
