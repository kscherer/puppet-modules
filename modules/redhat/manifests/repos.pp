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

  #setup archives for old fedora releases
  if $::operatingsystem == 'Fedora' and $::operatingsystemrelease < '18' {
    $fedora_mirror = 'https://archives.fedoraproject.org/pub/archive/fedora/linux'
  } else {
    $fedora_mirror = "${mirror}/fedora"
  }

  $redhat_dvd_repo = "redhat-${::operatingsystemrelease}-${::architecture}"

  $centos_mirror_base = "${mirror}/centos/${::lsbmajdistrelease}"
  $centos_mirror_os = "${centos_mirror_base}/os/${::architecture}"
  $centos_mirror_updates = "${centos_mirror_base}/updates/${::architecture}"
  $centos_mirror_extras = "${centos_mirror_base}/extras/${::architecture}"
  $centos_mirror_scl = "${centos_mirror_base}/SCL/${::architecture}"
  $centos_gpgkey = "${centos_mirror_os}/RPM-GPG-KEY-CentOS-${::lsbmajdistrelease}"

  #special case for fedora puppetlabs repo path
  case $::operatingsystem {
    Fedora:  { $repo_path='fedora/f'}
    default: { $repo_path='el/' }
  }

  $puppetlabs_mirror = "${mirror}/puppetlabs/yum/${repo_path}${::lsbmajdistrelease}"
  $puppetlabs_gpgkey = "${mirror}/puppetlabs/yum/RPM-GPG-KEY-puppetlabs"

  #declare all the repos virtually and realize the correct ones on
  #relevant platforms. Virtual define makes all classes within virtual
  @yum_repo {
    'epel':
      repo_gpgkey => "${mirror}/epel/RPM-GPG-KEY-EPEL-${::lsbmajdistrelease}",
      baseurl     => "${mirror}/epel/${::lsbmajdistrelease}/${::architecture}";
    'epel-testing':
      enabled     => '0',
      repo_gpgkey => "${mirror}/epel/RPM-GPG-KEY-EPEL-${::lsbmajdistrelease}",
      baseurl     => "${mirror}/epel/testing/${::lsbmajdistrelease}/${::architecture}";
    'redhat-dvd':
      baseurl => "${mirror}/repos/${redhat_dvd_repo}";
    'redhat-dvd2':
      baseurl => "${mirror}/repos/${redhat_dvd_repo}-dvd2";
    'redhat-dvd-client':
      baseurl => "${mirror}/repos/${redhat_dvd_repo}/Client";
    'redhat-dvd-workstation':
      baseurl => "${mirror}/repos/${redhat_dvd_repo}/Workstation";
    'fedora-updates':
      baseurl => "${fedora_mirror}/updates/${::operatingsystemrelease}/${::architecture}";
    'fedora-everything':
      baseurl => "${fedora_mirror}/releases/${::operatingsystemrelease}/Everything/${::architecture}/os";
    'centos-os':
      repo_gpgkey => $centos_gpgkey,
      baseurl     => $centos_mirror_os;
    'centos-updates':
      repo_gpgkey => $centos_gpgkey,
      baseurl     => $centos_mirror_updates;
    'centos-extras':
      repo_gpgkey => $centos_gpgkey,
      baseurl     => $centos_mirror_extras;
    'centos-scl':
      repo_gpgkey => $centos_gpgkey,
      baseurl     => $centos_mirror_scl;
    'puppetlabs':
      repo_gpgkey => $puppetlabs_gpgkey,
      baseurl     => "${puppetlabs_mirror}/products/${::architecture}";
    'puppetlabs-deps':
      repo_gpgkey => $puppetlabs_gpgkey,
      baseurl     => "${puppetlabs_mirror}/dependencies/${::architecture}";
    'activemq':
      baseurl => 'http://yow-mirror.wrs.com/mirror/activemq/6';
    'collectd':
      baseurl => "${mirror}/collectd/${::lsbmajdistrelease}";
  }

  #setup repos depending on which flavour of redhat
  case $::operatingsystem {
    'CentOS': {
      realize( Yum_repo['centos-os'] )
      realize( Yum_repo['centos-updates'] )
      if ( $::lsbmajdistrelease != '5' ) {
        realize( Yum_repo['centos-extras'] )
        realize( Yum_repo['centos-scl'] )
      }
      realize( Yum_repo['epel'] )
      realize( Yum_repo['epel-testing'] )
      realize( Yum_repo['collectd'] )
      realize( Yum_repo['puppetlabs'] )
      realize( Yum_repo['puppetlabs-deps'] )
      package {
        'epel-release':
          ensure  => installed,
          require => Yumrepo['epel'];
      }
    }
    'Fedora': {
      realize( Yum_repo['fedora-updates'], Yum_repo['fedora-everything'] )
      if $::operatingsystem == 'Fedora' and $::operatingsystemrelease > '16' and $::operatingsystemrelease < '21' {
        realize( Yum_repo['puppetlabs'] )
        realize( Yum_repo['puppetlabs-deps'] )
        package {
          'puppetlabs-release':
            ensure  => installed,
            require => Yumrepo['puppetlabs'];
        }
      }
    }
    'RedHat': {
      if $::lsbmajdistrelease == '5' {
        realize( Yum_repo['redhat-dvd-client'] )
        realize( Yum_repo['redhat-dvd-workstation'] )
        if $::architecture == 'x64_64' {
          realize( Yum_repo['redhat-dvd2'] )
        }
      } else {
        realize( Yum_repo['redhat-dvd'] )
      }
      if $::lsbmajdistrelease == '6' {
        realize( Yum_repo['redhat-dvd-workstation'] )
      }
      realize( Yum_repo['puppetlabs'] )
      realize( Yum_repo['puppetlabs-deps'] )
      realize( Yum_repo['epel'] )
      #subscription manager needs this file
      file {
        '/etc/yum.repos.d/redhat.repo':
          ensure => present;
      }
      package {
        'epel-release':
          ensure  => installed,
          require => Yumrepo['epel'];
      }
    }
    default: { fail('Unsupported Operating System') }
  }
}
