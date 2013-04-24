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
    'it':
      source  => 'puppet:///modules/wr/sudoers.d/it';
    'scmg':
      source  => 'puppet:///modules/wr/sudoers.d/scmg';
    }
}
