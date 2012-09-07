#
class git::cgit {
  package {
    'cgit':
      ensure => installed;
  }
}
