#On debian the default mail program is exim and this class
#sets it up so that mailx will use exim and send mail to
#prod-webmail.wrs.com
class exim4 {
  package {
    'exim4':
      ensure => installed;
  }

  service {
    'exim4' :
      ensure     => stopped,
      enable     => false,
      subscribe  => Package [ 'exim4' ],
      hasrestart => true,
      hasstatus  => true;
  }

  file {
    'update-exim4.conf.conf' :
      path   => '/etc/exim4/update-exim4.conf.conf',
      source => 'puppet:///modules/exim4/update-exim4.conf.conf',
      mode   => '0644',
      owner  => root,
      group  => root
  }

  exec {
    '/usr/sbin/update-exim4.conf' :
      subscribe   => File [ 'update-exim4.conf.conf' ],
      refreshonly => true
  }
}
