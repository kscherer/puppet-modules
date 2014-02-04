#
class git::package {
  include git::params

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease == '5' {
    redhat::yum_repo {
      'git':
        ensure  => absent,
        baseurl => 'http://yow-mirror.wrs.com/mirror/git/5';
    }
  }

  ensure_resource('package', $git::params::package_name, {'ensure' => 'installed' })
  ensure_resource('package', 'git-email',                {'ensure' => 'installed' })
}
