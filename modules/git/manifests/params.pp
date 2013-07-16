class git::params {
  case $::osfamily {
    'Debian': {
      $package_name   = 'git-core'
      $daemon         = '/usr/lib/git-core/git-daemon'
      $daemon_package = 'git-daemon-sysvinit'
      $docroot        = '/var/www'
      $python_git     = 'python-git'
      $python_json    = 'python-simplejson'
    }
    'RedHat': {
      $package_name   = 'git'
      $daemon         = '/usr/bin/git-daemon'
      $daemon_package = 'git-daemon'
      $docroot        = '/var/www/html'
      $python_git     = 'GitPython'
      $python_json    = 'python-json'
    }
    'Suse': {
      $package_name   = 'git'
      $daemon         = '/usr/bin/git-daemon'
      $daemon_package = 'git-daemon'
      $docroot        = '/var/www/html'
      $python_git     = 'python-GitPython'
      $python_json    = 'python-simplejson'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }
}
