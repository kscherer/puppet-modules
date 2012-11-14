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
  define redhat::named_yumrepo( $baseurl ){
    @yumrepo {
      $name:
        baseurl => $baseurl,
        descr   => $name,
    }
  }

  #declare all the repos virtually and realize the correct ones on
  #relevant platforms
  redhat::named_yumrepo {
    'epel':
      baseurl => "${mirror}/epel/${::lsbmajdistrelease}/${::architecture}";
    'redhat-dvd':
      baseurl => "${mirror}/repos/${redhat_dvd_repo}";
    'fedora-updates':
      baseurl => "${mirror}/fedora/updates/${::operatingsystemrelease}/${::architecture}";
    'fedora-everything':
      baseurl => "${mirror}/fedora/releases/${::operatingsystemrelease}/Everything/${::architecture}";
    'rhel6-optional':
      baseurl => "${mrepo_mirror}/rhel6ws-${::architecture}/RPMS.optional";
    'rhel6-updates':
      baseurl => "${mrepo_mirror}/rhel6ws-${::architecture}/RPMS.updates";
    'centos-os':
      baseurl => "${mirror}/centos/${::lsbmajdistrelease}/os/${::architecture}/";
    'centos-updates':
      baseurl => "${mirror}/centos/${::lsbmajdistrelease}/updates/${::architecture}/";
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
      realize( Yumrepo['centos-os'] )
      realize( Yumrepo['centos-updates'] )
      realize( Yumrepo['epel'] )
      realize( Yumrepo['puppetlabs'] )
      if ( $::lsbmajdistrelease == '6' ) {
        realize( Yumrepo['passenger'] )
        realize( Yumrepo['foreman'] )
        realize( Yumrepo['graphite'] )
      }
    }
    Fedora: {
      realize( Yumrepo['fedora-updates'], Yumrepo['fedora-everything'] )
      if $::operatingsystemrelease >= 16 {
        realize( Yumrepo['puppetlabs-fedora'] )
      } else {
        realize( Yumrepo['puppetlabs'] )
      }
    }
    RedHat: {
      realize( Yumrepo['redhat-dvd'] )
      realize( Yumrepo['epel'] )
      realize( Yumrepo['puppetlabs'] )
      if ( $::lsbmajdistrelease == '6' ) {
        realize( Yumrepo['rhel6-updates'] )
        realize( Yumrepo['rhel6-optional'] )
      }
    }
    default: { fail('Unsupported Operating System') }
  }
}
