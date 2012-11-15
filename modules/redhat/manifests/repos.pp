#Setup the correct yum repos for redhat systems
class redhat::repos {

  #by cleaning the metadata the next yum command will refresh the database
  exec { 'yum_reload':
    command     => '/usr/bin/yum clean metadata',
    refreshonly => true
  }

  #defaults for all yum repos
  Yumrepo {
    enabled  => 1,
    gpgcheck => 0,
    notify   => Exec[ 'yum_reload' ],
  }

  #only puppet managed repo files in /etc/yum.repos.d
  file {
    '/etc/yum.repos.d/':
      ensure  => directory,
      recurse => true,
      purge   => true,
      owner   => root,
      group   => root,
      notify  => Exec[ 'yum_reload' ];
  }

  $mirror = $::hostname ? {
    /^pek.*$/ => 'http://pek-mirror.wrs.com/mirror',
    /^ala.*$/ => 'http://ala-mirror.wrs.com/mirror',
    default   => 'http://yow-mirror.wrs.com/mirror',
  }

  $mrepo_mirror = "${mirror}/mrepo/repos"
  $redhat_dvd_repo = "redhat-${::operatingsystemrelease}-${::architecture}-repo"

  #this exists solely to stop yum complaining about missing name
  define named_yumrepo( $baseurl, $gpgkey = undef ){

    $real_gpgcheck = $gpgkey ? {
      undef   => '0',
      default => '1',
    }

    yumrepo {
      $name:
        baseurl  => $baseurl,
        descr    => $name,
        gpgcheck => $real_gpgcheck,
        gpgkey   => $gpgkey,
    }
    #this is necessary to keep puppet from deleting the repo files
    file {
      "/etc/yum.repos.d/${name}.repo":
        ensure => file;
    }
  }

  $centos_mirror_base = "${mirror}/centos/${::lsbmajdistrelease}"
  $centos_mirror_os = "${centos_mirror_base}/os/${::architecture}/"
  $centos_mirror_updates = "${centos_mirror_base}/updates/${::architecture}/"
  $centos_gpgkey = "${centos_mirror_os}/RPM-GPG-KEY-CentOS-${::lsbmajdistrelease}"

  #declare all the repos virtually and realize the correct ones on
  #relevant platforms
  @named_yumrepo {
    'epel':
      baseurl => "${mirror}/epel/${::lsbmajdistrelease}/${::architecture}";
    'redhat-dvd':
      baseurl => "${mirror}/repos/${redhat_dvd_repo}";
    'fedora-updates':
      baseurl => "${mirror}/fedora/updates/${::operatingsystemrelease}/${::architecture}";
    'fedora-everything':
      baseurl => "${mirror}/fedora/releases/${::operatingsystemrelease}/Everything/${::architecture}/os";
    'rhel6-optional':
      baseurl => "${mrepo_mirror}/rhel6ws-${::architecture}/RPMS.optional";
    'rhel6-updates':
      baseurl => "${mrepo_mirror}/rhel6ws-${::architecture}/RPMS.updates";
    'centos-os':
      gpgkey  => $centos_gpgkey,
      baseurl => $centos_mirror_os;
    'centos-updates':
      gpgkey  => $centos_gpgkey,
      baseurl => $centos_mirror_updates;
    'puppetlabs':
      baseurl => "${mrepo_mirror}/puppetlabs-rh${::lsbmajdistrelease}-${::architecture}/RPMS.all";
    'puppetlabs-fedora':
      baseurl => "${mrepo_mirror}/puppetlabs-f${::operatingsystemrelease}-${::architecture}/RPMS.all";
    'passenger':
      baseurl => "${mrepo_mirror}/passenger-rh6-${::architecture}/RPMS.main";
    'foreman':
      baseurl => "http://ala-mirror.wrs.com/mirror/mrepo/repos/foreman-rh6-${::architecture}/RPMS.all";
    'activemq':
      baseurl => 'http://yow-mirror.wrs.com/mirror/activemq';
    'graphite':
      baseurl => 'http://ala-mirror.wrs.com/mirror/graphite';
  }

  #setup repos depending on which flavour of redhat
  case $::operatingsystem {
    CentOS: {
      realize( Named_yumrepo['centos-os'] )
      realize( Named_yumrepo['centos-updates'] )
      realize( Named_yumrepo['epel'] )
      realize( Named_yumrepo['puppetlabs'] )
      if ( $::lsbmajdistrelease == '6' ) {
        realize( Named_yumrepo['passenger'] )
        realize( Named_yumrepo['foreman'] )
        realize( Named_yumrepo['graphite'] )
      }
    }
    Fedora: {
      realize( Named_yumrepo['fedora-updates'], Named_yumrepo['fedora-everything'] )
      if $::operatingsystemrelease >= 16 {
        realize( Named_yumrepo['puppetlabs-fedora'] )
      } else {
        realize( Named_yumrepo['puppetlabs'] )
      }
    }
    RedHat: {
      realize( Named_yumrepo['redhat-dvd'] )
      realize( Named_yumrepo['epel'] )
      realize( Named_yumrepo['puppetlabs'] )
      if ( $::lsbmajdistrelease == '6' ) {
        realize( Named_yumrepo['rhel6-updates'] )
        realize( Named_yumrepo['rhel6-optional'] )
      }
    }
    default: { fail('Unsupported Operating System') }
  }
}
