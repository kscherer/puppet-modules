#Install and keep up to date the wr bin repo
class git::wr_bin_repo {
  vcsrepo {
    '/git/bin':
      ensure   => 'latest',
      provider => 'git',
      source   => 'git://ala-git.wrs.com/bin',
      user     => 'git',
      revision => 'master';
  }
  Class['git::wr_bin_repo'] -> Anchor['git::end']
}
