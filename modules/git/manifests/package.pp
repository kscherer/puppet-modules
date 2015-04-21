#
class git::package {
  include git::params

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease < '7' {
    redhat::yum_repo {
      'git':
        ensure  => present,
        baseurl => "http://yow-mirror.wrs.com/mirror/git/${::lsbmajdistrelease}";
    }
  }

  ensure_resource('package', $git::params::package_name, {'ensure' => 'installed' })
  ensure_resource('package', 'git-email',                {'ensure' => 'installed' })
}
