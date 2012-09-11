#
class git::git-daemon {
  package {
    'git-daemon':
      ensure => latest;
  }

  #this will enable the git daemon
  file {
    '/etc/xinetd.d/git':
      ensure => present,
      owner  => root,
      group  => root,
      mode   => '0644',
      notify => Service['xinetd'],
      source => 'puppet:///modules/git/xinetd.git.conf';
  }

  #which requires xinetd to be started
  service {
    'xinetd':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true;
  }
}
