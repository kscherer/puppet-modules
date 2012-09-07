#
class redhat::autoupdate {
  #enable auto update using cron
  package {
    ['yum-cron', 'bash-completion']:
      ensure => installed;
    'yum-updatesd':
      ensure => absent;
  }

  service {
    'yum-cron':
      ensure    => running,
      enable    => true,
      hasstatus => true;
  }
}
