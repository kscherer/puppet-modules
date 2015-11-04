#
class debian::debian(
  $mirror_base = "http://${::location}-mirror.wrs.com/mirror",
) {

  #koan needs the following packages
  package {
    [ 'yum', 'python-simplejson', 'parted' ]:
      ensure  => installed,
      require => Apt::Source['debian_mirror_wheezy'];
  }

  include apt
  #base all debian machines on wheezy
  class { 'apt::release' : release_id => 'stable' }

  apt::source {
    'debian_mirror_stable':
      ensure      => absent;
    'debian_mirror_wheezy':
      location    => "${mirror_base}/debian",
      release     => 'wheezy',
      repos       => 'main contrib non-free';
    'debian_mirror_wheezy_updates':
      location    => "${mirror_base}/debian",
      release     => 'wheezy-updates',
      repos       => 'main contrib non-free';
    'debian_mirror_wheezy_security':
      location    => 'http://security.debian.org/',
      release     => 'wheezy/updates',
      repos       => 'main contrib non-free';
    'yow_puppetlabs_mirror':
      location    => "${mirror_base}/puppetlabs/apt",
      release     => 'wheezy',
      include_src => false,
      repos       => 'main dependencies';
    'debian_mirror_jessie':
      location    =>  "${mirror_base}/debian",
      release     => 'jessie',
      repos       => 'main contrib non-free';
  }

  #lsb facts require the following
  ensure_resource('package', 'lsb-release', {'ensure' => 'installed' })
}
