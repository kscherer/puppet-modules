#
class git {
  include git::params
  ensure_resource('package', $git::params::package_name, {'ensure' => 'installed' })
  ensure_resource('package', 'git-email',                {'ensure' => 'installed' })
}
