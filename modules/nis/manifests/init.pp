# Setup up NIS and autofs
class nis {

  #needed so that network service can be restarted
  include network

  #cannot automount nfs partitions without nfs client
  include nfs

  $nis_server = $::hostname ? {
    /^pek.*$/ => '128.224.160.17',
    /^ala.*$/ => '147.11.49.57',
    /^yow.*$/ => '128.224.144.20',
  }

  if $::operatingsystem == 'Ubuntu' {
    $nis_package = 'nis'
    if $::lsbdistrelease == '10.04' {
      $ypconf = "domain swamp server $nis_server"
      $nis_hasstatus = false
      $nis_service = 'nis'
      $nis_status = 'ypbind'
    } else {
      $ypconf = "ypserver $nis_server\n"
      $nis_service = 'ypbind'
      $nis_hasstatus = true
    }
  } else {
    $ypconf = "domain swamp server $nis_server"
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
      File_line['nisdomain'] -> Service['nis']
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
      content => $ypconf,
      owner   => root, group => root, mode => '0644',
      require => Package['nis'];
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/nis/nsswitch.conf',
      owner   => root, group => root, mode => '0644',
      require => Package['nis'];
    '/etc/auto.master':
      content => template('nis/auto.master.erb'),
      owner   => root, group => root, mode => '0644',
      require => Package['autofs'];
    ['/net','/folk']:
      ensure  => directory,
      notify  => Service['autofs'];
  }

  #On Redhat 5.x and Suse the portmap service is needed
  $isRedHat5 = ($::operatingsystem =~ /(RedHat|CentOS)/ and $::operatingsystemrelease =~ /5.*/)
  $isSuse = ($::operatingsystem =~ /(OpenSuSE|SLED|SLES)/)
  $isSuse11plus = ($isSuse and $::operatingsystemrelease =~ /1[1-2]/ )

  if $isRedHat5 or $isSuse {
    $portmap_name = $isSuse11plus ?{
      true  => 'rpcbind',
      false => 'portmap',
    }

    package {
      'portmap':
        ensure => installed,
        name   => $portmap_name;
    }

    service {
      'portmap':
        ensure     => running,
        name       => $portmap_name,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package['portmap'],
        before     => Service['nis'],
    }
  }

  service {
    'nis':
      ensure     => running,
      name       => $nis_service,
      enable     => true,
      hasrestart => true,
      hasstatus  => $nis_hasstatus,
      status     => $nis_status,
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
