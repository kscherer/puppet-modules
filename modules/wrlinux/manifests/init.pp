#
class wrlinux {
  $arch = $hardwaremodel ? {
    x86_64 => "-x86_64",
    amd64 => "-x86_64",
    default => "",
  }

  #fake out CentOS to use the RedHat package list
  $os = $operatingsystem ? {
      CentOS => "RedHat",
      default => $operatingsystem,
  }

  #Enable package list for Ubuntu 10.10 and Fedora 14
  $osrelease = $operatingsystem ? {
    Ubuntu => "10.04",
    default => $operatingsystemrelease,
  }

  $hostos="${os}-${osrelease}${arch}"
  #notice "Looking up host OS $hostos"
  $package_list = extlookup( $hostos )

  #only include a package if it has not already been defined
  define smart_package() {
    if ! defined(Package["$name"]) {
      package {
        "$name":
          ensure => installed;
      }
    }
  }
  smart_package { $package_list : ensure => installed }
}
