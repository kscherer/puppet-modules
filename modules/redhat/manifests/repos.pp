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

  define redhat::delete_repo() {
    file {
      $name:
        ensure => absent,
        path   => "/etc/yum.repos.d/${name}.repo",
        notify => Exec[ 'yum_reload' ],
    }
  }

  #make sure all other repos are gone
  redhat::delete_repo {
    [ 'fedora', 'fedora-updates-testing', 'cobbler-config',
      'CentOS-Base','CentOS-Debuginfo', 'CentOS-Media',
      'puppet', 'redhat_dvd', 'rhel-source',
      'puppet-el6', 'puppet-el5', 'epel', 'redhat',
      'redhat-el5', 'rhel-debuginfo', 'centos_dvd' ]:
  }

  $yow_mirror = 'http://yow-mirror.wrs.com/mirror'
  $yow_mrepo_mirror = "${yow_mirror}/mrepo/repos"
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
    "epel-el5-$::architecture":
      baseurl => "${yow_mrepo_mirror}/rhel5c-${::architecture}/RPMS.epel";
    "epel-el6-${::architecture}":
      baseurl => "${yow_mrepo_mirror}/rhel6ws-${::architecture}/RPMS.epel";
    'redhat-dvd':
      baseurl => "${yow_mirror}/repos/${redhat_dvd_repo}";
    'centos-dvd':
      #This is a link to the latest CentOS DVD release for 6
      #and 5.5 for CentOS 5 as later versions of Redhat are
      #officially not supported by wrlinux
      baseurl => "$yow_mirror/repos/centos-${::lsbmajdistrelease}-${::architecture}";
    'fedora-updates':
      baseurl =>
        "${yow_mirror}/fedora/updates/${::operatingsystemrelease}/${::architecture}";
    'fedora-everything':
      baseurl =>
        "${yow_mirror}/fedora/releases/${::operatingsystemrelease}/Everything/${::architecture}/os/Packages";
    'mcollective':
      baseurl => "${yow_mirror}/mcollective";
    'rhel6-optional':
      baseurl => "${yow_mrepo_mirror}/rhel6ws-${::architecture}/RPMS.optional";
    'rhel6-updates':
      baseurl => "${yow_mrepo_mirror}/rhel6ws-${::architecture}/RPMS.updates";
    'centos5-updates':
      baseurl => "${yow_mrepo_mirror}/centos5-${::architecture}/RPMS.updates";
    'centos6-updates':
      baseurl => "${yow_mrepo_mirror}/centos6-${::architecture}/RPMS.updates";
    'puppetlabs-rh4':
      baseurl => "${redhat::repos::yow_mrepo_mirror}/puppetlabs-rh5-${::architecture}/RPMS.both";
    'puppetlabs-rh5':
      baseurl => "${redhat::repos::yow_mrepo_mirror}/puppetlabs-rh5-${::architecture}/RPMS.both";
    'puppetlabs-rh6':
      baseurl => "${redhat::repos::yow_mrepo_mirror}/puppetlabs-rh6-${::architecture}/RPMS.both";
    'passenger-rh6':
      baseurl => "${redhat::repos::yow_mrepo_mirror}/passenger-rh6-${::architecture}/RPMS.all";
  }

  case $::operatingsystemrelease {
    /^4.*$/: { $major_release=4 }
    /^5.*$/: { $major_release=5 }
    /^6.*$/: { $major_release=6 }
    default: {  }
  }

  #setup repos depending on which flavour of redhat
  realize( Yumrepo['mcollective'] )
  case $::operatingsystem {
    CentOS: {
      realize( Yumrepo['centos-dvd'] )
      realize( Yumrepo["epel-el${major_release}-${::architecture}"] )
      realize( Yumrepo["centos${major_release}-updates"] )
      realize( Yumrepo["puppetlabs-rh${major_release}"] )
      if ( $major_release == '6' ) {
        realize( Yumrepo["passenger-rh${major_release}"] )
      }
    }
    Fedora: {
      realize( Yumrepo['fedora-updates'], Yumrepo['fedora-everything'] )
      realize( Yumrepo['puppetlabs-rh6'] )
    }
    RedHat: {
      realize( Yumrepo['redhat-dvd'] )
      realize( Yumrepo["epel-el${major_release}-${::architecture}"] )
      realize( Yumrepo["puppetlabs-rh${major_release}"] )
      if ( $major_release == '6' ) {
        realize( Yumrepo["rhel${major_release}-updates"] )
        realize( Yumrepo["rhel${major_release}-optional"] )
      }
    }
    default: { fail('Unsupported Operating System') }
  }
}
