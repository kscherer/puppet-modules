#
class git {

  $git_package_name   = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'git-core',
    default           => 'git',
  }

  package {
    [$git_package_name, 'git-email']:
      ensure => present;
  }
}
