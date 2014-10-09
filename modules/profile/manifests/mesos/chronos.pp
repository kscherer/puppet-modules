#Run chronos
class profile::mesos::chronos {

  #install chronos from tarball
  $chronos_tgz = 'chronos.tgz'

  exec {
    'chronos_tgz':
      command => "/usr/bin/wget -O /root/${chronos_tgz} \
      http://${::location}-mirror.wrs.com/mirror/mesos/${chronos_tgz}",
      creates => "/root/${chronos_tgz}";
    'extract_chronos':
      command => "/usr/bin/tar -C /usr/local -xzf /root/${chronos_tgz}",
      unless  => '/usr/bin/test -d /usr/local/chronos',
      require => Exec['chronos_tgz'];
  }


  #upstart config to manage chronos service
  file {
    '/etc/init/chronos.conf':
      ensure => present,
      source => 'puppet:///modules/wr/chronos.conf',
      notify => Service['chronos'];
  }

  service {
    'chronos':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider   => upstart;
  }
}
