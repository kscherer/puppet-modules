#
class debian {
  include exim4

  case $::operatingsystem {
    'Ubuntu': {
      include debian::ubuntu
      Class['debian'] -> Class['debian::ubuntu']
      $repo=yow-mirror_ubuntu
    }
    'Debian': {
      include debian::debian
      Class['debian'] -> Class['debian::debian']
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

  #show versions when searching for packages with aptitude
  file {
    '/etc/apt/apt.conf.d/90aptitude':
      ensure  => file,
      content => 'Aptitude "";
Aptitude::CmdLine "";
Aptitude::CmdLine::Show-Versions "true";
Aptitude::CmdLine::Package-Display-Format "%c%a%M %p# - %d%V#";';
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
      unless  => '/usr/bin/apt-key list | /bin/grep -q \'Konrad Scherer\'';
    'install-wenzong-key':
      command => '/usr/bin/apt-key add /etc/apt/wenzong.public.key',
      require => File['/etc/apt/wenzong.public.key'],
      unless  => '/usr/bin/apt-key list | /bin/grep -q \'Wenzong Fan\'';
  }
}
