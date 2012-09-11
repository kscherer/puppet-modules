#
class git::cgit {
  package {
    ['cgit','highlight']:
      ensure => installed;
  }

  file {
    '/etc/cgitrc':
      ensure => present,
      source => 'puppet:///modules/git/cgitrc';
  }

  service {
    'httpd':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true;
  }
}
