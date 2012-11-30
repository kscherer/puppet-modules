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

  $mirror_host = hiera('mirror')
  $mirror = "http://${mirror_host}/mirror"
  $mrepo_mirror = "${mirror}/mrepo/repos"
  $redhat_dvd_repo = "redhat-${::operatingsystemrelease}-${::architecture}-repo"

  $centos_mirror_base = "${mirror}/centos/${::lsbmajdistrelease}"
  $centos_mirror_os = "${centos_mirror_base}/os/${::architecture}"
  $centos_mirror_updates = "${centos_mirror_base}/updates/${::architecture}"
  $centos_gpgkey = "${centos_mirror_os}/RPM-GPG-KEY-CentOS-${::lsbmajdistrelease}"

  $puppetlabs_mirror_el = "${mirror}/puppetlabs/yum/el/${::lsbmajdistrelease}"
  $puppetlabs_mirror_fedora = "${mirror}/puppetlabs/yum/fedora/f${::lsbmajdistrelease}"
  $puppetlabs_gpgkey = "${mirror}/puppetlabs/yum/RPM-GPG-KEY-puppetlabs"

  #declare all the repos virtually and realize the correct ones on
  #relevant platforms. Virtual define makes all classes within virtual
  @yum_repo {
    'epel':
      repo_gpgkey => "${mirror}/epel/RPM-GPG-KEY-EPEL-${::lsbmajdistrelease}",
      baseurl     => "${mirror}/epel/${::lsbmajdistrelease}/${::architecture}";
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
      repo_gpgkey => $centos_gpgkey,
      baseurl     => $centos_mirror_os;
    'centos-updates':
      repo_gpgkey => $centos_gpgkey,
      baseurl     => $centos_mirror_updates;
    'puppetlabs':
      repo_gpgkey => $puppetlabs_gpgkey,
      baseurl     => "${puppetlabs_mirror_el}/products/${::architecture}";
    'puppetlabs-deps':
      repo_gpgkey => $puppetlabs_gpgkey,
      baseurl     => "${puppetlabs_mirror_el}/dependencies/${::architecture}";
    'puppetlabs-fedora':
      repo_gpgkey => $puppetlabs_gpgkey,
      baseurl     => "${puppetlabs_mirror_fedora}/products/${::architecture}";
    'puppetlabs-fedora-deps':
      repo_gpgkey => $puppetlabs_gpgkey,
      baseurl     => "${puppetlabs_mirror_fedora}/dependencies/${::architecture}";
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
      realize( Yum_repo['centos-os'] )
      realize( Yum_repo['centos-updates'] )
      realize( Yum_repo['epel'] )
      realize( Yum_repo['puppetlabs'] )
      realize( Yum_repo['puppetlabs-deps'] )
      if ( $::lsbmajdistrelease == '6' ) {
        realize( Yum_repo['passenger'] )
        realize( Yum_repo['foreman'] )
      }
      package { 'epel-release': ensure => installed; }
    }
    Fedora: {
      realize( Yum_repo['fedora-updates'], Yum_repo['fedora-everything'] )
      realize( Yum_repo['puppetlabs-fedora'] )
      realize( Yum_repo['puppetlabs-fedora-deps'] )
    }
    RedHat: {
      realize( Yum_repo['redhat-dvd'] )
      realize( Yum_repo['epel'] )
      realize( Yum_repo['puppetlabs'] )
      if ( $::lsbmajdistrelease == '6' ) {
        realize( Yum_repo['rhel6-updates'] )
        realize( Yum_repo['rhel6-optional'] )
      }
      package { 'epel-release': ensure => installed; }
    }
    default: { fail('Unsupported Operating System') }
  }

  #make sure gpg keys are installed
  package { 'puppetlabs-release': ensure => installed; }
}
