#
class debian {

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  case $::operatingsystem {
    'Ubuntu': {
      $debian_variant='debian::ubuntu'
      $repo=yow-mirror_ubuntu
    }
    'Debian': {
      $debian_variant='debian::debian'
      $repo=debian_mirror_stable
    }
    default: { fail("Unsupported OS ${::operatingsystem}") }
  }

  anchor { 'debian::begin': }
  -> class { $debian_variant: }
  -> anchor { 'debian::end': }

  file {
    #show versions when searching for packages with aptitude
    '/etc/apt/apt.conf.d/90aptitude':
      ensure  => file,
      content => 'Aptitude "";
Aptitude::CmdLine "";
Aptitude::CmdLine::Show-Versions "true";
Aptitude::CmdLine::Package-Display-Format "%c%a%M %p# - %d%V#";
APT::Install-Recommends "0";';
  }

  include apt
  include unattended_upgrades

  # fsck of /boot/efi fails and causes boot to hang
  exec {
    'remove_efi_parition_from_fstab':
      command => '/bin/sed -i \'/\/boot\/efi/d\' /etc/fstab',
      onlyif  => '/bin/grep -q \'/boot/efi\' /etc/fstab';
  }

  $timezone=hiera('timezone','US/Pacific')
  # if system is in UTC timezone, switch it
  exec {
    'fix_timezone_if_utc':
      command => "/bin/echo \"${timezone}\" > /etc/timezone; /usr/sbin/dpkg-reconfigure -f noninteractive tzdata",
      onlyif  => '/bin/grep -q \'UTC\' /etc/timezone';
  }

  # squid deb proxy is installed on fileservers
  package {
    'squid-deb-proxy-client':
      ensure => absent;
  }
}
