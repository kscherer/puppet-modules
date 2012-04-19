# Setup up NIS and autofs
class nis {

  if $::operatingsystem == 'Ubuntu' and $::lsbdistrelease == '10.04' {
    $nis = 'nis'
    $nis_hasstatus = false
    $nis_status = 'ypbind'
  } else {
    $nis = 'ypbind'
    $nis_hasstatus = true
  }

  package {
    'nis':
      ensure => installed,
      name   => $nis;
    'autofs':
      ensure => installed;
  }

  #needed so that network service can be restarted
  include network

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
      content => 'domain swamp server 128.224.144.20',
      owner   => root, group => root, mode => '0644',
      require => Package['nis'];
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/nis/nsswitch.conf',
      owner   => root, group => root, mode => '0644',
      require => Package['nis'];
    '/etc/auto.master':
      source  => 'puppet:///modules/nis/auto.master',
      owner   => root, group => root, mode => '0644',
      require => Package['autofs'];
    ['/net','/folk']:
      ensure  => directory,
      notify  => Service['autofs'];
  }

  #On Redhat 5.x and Suse the portmap service is needed
  $isRedHat5 = ($::operatingsystem =~ /(RedHat|CentOS)/ and $::operatingsystemrelease =~ /5.*/)
  $isSuse = ($::operatingsystem =~ /(OpenSuSE|SLED|SLES)/)
  $isSuse11 = ($isSuse and $::operatingsystemrelease =~ /11/ )

  if $isRedHat5 or $isSuse {
    $portmap_name = $isSuse11 ?{
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
      name       => $nis,
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
