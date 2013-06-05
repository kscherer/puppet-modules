class git::params {
  case $::osfamily {
    'Debian': {
      $package_name   = 'git-core'
      $daemon_package = 'git-daemon-sysvinit'
    }
    'RedHat': {
      $package_name   = 'git'
      $daemon_package = 'git-daemon'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }
}
