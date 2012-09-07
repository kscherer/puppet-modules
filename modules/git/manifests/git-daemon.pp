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
      source => 'puppet:///modules/git/xinetd.get.conf';
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
