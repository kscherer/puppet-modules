# Setup up NIS and autofs
class nis {

  #needed so that network service can be restarted
  include network

  #cannot automount nfs partitions without nfs client
  include nfs

  $nis_server = $::hostname ? {
    'ala-git' => ['neptune','saturn'],
    /^pek.*$/ => ['128.224.160.15'],
    /^ala.*$/ => ['ala-adnis1','ala-adnis2'],
    /^yow.*$/ => ['yow-adnis1','yow-adnis2'],
  }

  if $::operatingsystem == 'Ubuntu' {
    $nis_package = 'nis'
    if $::operatingsystemrelease == '10.04' {
      $nis_hasstatus = false
      $nis_service = 'nis'
      $nis_status = 'ypbind'
    } else {
      $nis_service = 'ypbind'
      $nis_hasstatus = true
    }
  } else {
    $nis_package = 'ypbind'
    $nis_service = 'ypbind'
    $nis_hasstatus = true
  }

  package {
    'nis':
      ensure => installed,
      name   => $nis_package;
    ['autofs', 'tcsh']:
      ensure => installed;
  }

  case $::osfamily {
    'RedHat': {
      file_line {
        'nisdomain':
          ensure => present,
          path   => '/etc/sysconfig/network',
          line   => 'NISDOMAIN=swamp',
          notify => Service['network'];
      }
      File_line['nisdomain'] -> Service['network'] -> Service['nis']
    }
    'Debian','Suse': {
      file {
        '/etc/defaultdomain':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => 'swamp',
          notify  => Service['nis'];
      }
    }
    default: {}
  }

  file {
    '/etc/yp.conf':
      content => template('nis/yp.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Package['nis'];
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/nis/nsswitch.conf',
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Package['nis'];
    '/etc/auto.master':
      content => template('nis/auto.master.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Package['autofs'];
    ['/net','/folk']:
      ensure  => directory,
      notify  => Service['autofs'];
  }

  #On Redhat 5.x the portmap service is needed
  $isRedHat5 = $::osfamily == 'RedHat' and $::operatingsystemrelease =~ /^5.*/
  $isUbuntu1004 = $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '10.04'
  $isUbuntu12 = $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease >= '12'

  if $isRedHat5 or $isUbuntu1004 {
    $rpc_package = 'portmap'
    $rpc_service = 'portmap'
  } elsif $isUbuntu12 {
    $rpc_package = 'rpcbind'
    $rpc_service = 'portmap'
  } else {
    $rpc_package = 'rpcbind'
    $rpc_service = 'rpcbind'
  }

  package {
    'rpc':
      ensure => installed,
      name   => $rpc_package;
  }

  service {
    'rpc':
      ensure     => running,
      name       => $rpc_service,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package['rpc'],
      before     => Service['nis'],
  }

  service {
    'nis':
      ensure     => running,
      name       => $nis_service,
      enable     => true,
      hasrestart => true,
      hasstatus  => $nis_hasstatus,
      status     => $nis_status,
      require    => Service['rpc'],
      before     => Service['autofs'],
      subscribe  => [ File['/etc/yp.conf'], File['/etc/nsswitch.conf'],
                      Package['nis']];
  }

  service {
    'autofs':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => [ File['/etc/auto.master'], Package['autofs'],
                      File['/folk']];
  }
}
