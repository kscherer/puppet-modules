#Used to install all the packages required to build wrlinux
#A perl script run using cron on yow-lpgbld-master creates
#the csv file used by extlookup
class wrlinux {

  #only 64 bit hosts have the extension
  $arch = $::hardwaremodel ? {
    x86_64  => '-x86_64',
    amd64   => '-x86_64',
    default => '',
  }

  #fake out CentOS to use the RedHat package list
  $os = $::operatingsystem ? {
      CentOS  => 'RedHat',
      default => $::operatingsystem,
  }

  #Enable package list for Ubuntu 10.10
  $osrelease = $::operatingsystem ? {
    Ubuntu  => $::lsbdistrelease,
    default => $::operatingsystemrelease,
  }

  $hostos="${os}-${osrelease}${arch}"
  $package_list = extlookup( $hostos )

  #only include a package if it has not already been defined. The
  #difficulty of defining a package in multiple files is a known
  #problem with puppet.
  define wrlinux::smart_package() {
    if ! defined(Package[$name]) {
      package {
        $name:
          ensure => installed;
      }
    }
  }
  wrlinux::smart_package { $package_list : }
}
