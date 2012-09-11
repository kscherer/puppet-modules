#
class git {

  $git_package_name   = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => 'git-core',
    default           => 'git',
  }

  ensure_resource('package', $git_package_name, {'ensure' => 'latest' })
  ensure_resource('package', 'git-email',       {'ensure' => 'latest' })
}
