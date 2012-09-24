#
class debian {
  include exim4

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  $mirror_base = $::hostname ? {
    /^yow.*/ => 'http://yow-mirror.wrs.com/mirror',
    /^pek.*/ => 'http://pek-mirror.wrs.com/mirror',
  }

  #Sources are managed by puppet only
  class {
    'apt':
      purge_sources_list => true;
  }

  case $::operatingsystem {
    'Ubuntu': {
      class { 'debian::ubuntu' : mirror_base => $mirror_base }
      $repo=yow-mirror_ubuntu
    }
    'Debian': {
      class { 'debian::debian' : mirror_base => $mirror_base }
      $repo=debian_mirror_stable
    }
    default: { fail("Unsupported OS $::operatingsystem") }
  }

  #needed to allow puppet to set passwords
  package {
    ['libshadow-ruby1.8','unattended-upgrades']:
      ensure  => latest,
      require => Apt::Source[$repo];
  }

  file {
    #show versions when searching for packages with aptitude
    '/etc/apt/apt.conf.d/90aptitude':
      ensure  => file,
      content => 'Aptitude "";
Aptitude::CmdLine "";
Aptitude::CmdLine::Show-Versions "true";
Aptitude::CmdLine::Package-Display-Format "%c%a%M %p# - %d%V#";';
      #Prefer package from puppetlabs
    '/etc/apt/preferences.d/01puppetlabs':
      ensure  => file,
      content => 'Package: *
Pin: release l=PuppetLabs
Pin-Priority: 900';
  }

  file {
    #setup for unattended upgrades
    '/etc/apt/apt.conf.d/02periodic':
      source => 'puppet:///modules/debian/02periodic';
    '/etc/apt/apt.conf.d/50unattended-upgrades':
      source => 'puppet:///modules/debian/50unattended-upgrades';
    '/etc/apt/public.key':
      source => 'puppet:///modules/debian/public.key';
    '/etc/apt/wenzong.public.key':
      source => 'puppet:///modules/debian/wenzong.public.key';
  }

  #This is for the key that signs the windriver internal reprepro apt repo
  exec {
    'install-key':
      command => '/usr/bin/apt-key add /etc/apt/public.key',
      require => File['/etc/apt/public.key'],
      before  => Apt::Source[$repo],
      unless  => '/usr/bin/apt-key list | /bin/grep -q \'Konrad Scherer\'';
    'install-wenzong-key':
      command => '/usr/bin/apt-key add /etc/apt/wenzong.public.key',
      require => File['/etc/apt/wenzong.public.key'],
      before  => Apt::Source[$repo],
      unless  => '/usr/bin/apt-key list | /bin/grep -q \'Wenzong Fan\'';
  }
}
