#
class redhat::autoupdate(
  $yum_cron_ensure = 'running'
) {
  #enable auto update using cron
  package {
    ['yum-cron', 'bash-completion']:
      ensure => installed;
    'yum-updatesd':
      ensure => absent;
  }

  service {
    'yum-cron':
      ensure    => $yum_cron_ensure,
      enable    => true,
      hasstatus => true;
  }
}
