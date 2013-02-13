#
class wr::yow_git {
  include wr::yow-common

  redhat::yum_repo {
    'git':
      baseurl  => 'http://yow-mirror.wrs.com/mirror/git/5';
  }

  package {
    ['git', 'git-daemon']:
      ensure  => installed,
      require => Yumrepo['git'];
  }

  sudo::conf {
    'leads':
      source  => 'puppet:///modules/wr/sudoers.d/leads';
  }
}
