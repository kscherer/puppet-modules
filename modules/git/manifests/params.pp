class git::params {
  case $::osfamily {
    'Debian': {
      $package_name   = 'git-core'
      $daemon         = '/usr/lib/git-core/git-daemon'
      $daemon_package = 'git-daemon-sysvinit'
    }
    'RedHat': {
      $package_name   = 'git'
      $daemon         = '/usr/bin/git-daemon'
      $daemon_package = 'git-daemon'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }
}
