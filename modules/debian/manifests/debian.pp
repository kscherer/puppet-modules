#
class debian::debian(
  $mirror_base = "http://${::location}-mirror.wrs.com/mirror",
) {

  include apt
  #base all debian machines on jessie
  class { 'apt::release' : release_id => 'jessie' }

  apt::source {
    'yow_puppetlabs_mirror':
      location    => "${mirror_base}/puppetlabs/apt",
      release     => 'jessie',
      include_src => false,
      repos       => 'main dependencies';
    'debian_mirror_jessie':
      location    =>  "${mirror_base}/debian",
      release     => 'jessie',
      repos       => 'main contrib non-free';
    'debian_mirror_jessie_updates':
      location    => "${mirror_base}/debian",
      release     => 'jessie-updates',
      repos       => 'main contrib non-free';
    'debian_mirror_jessie_security':
      location    => 'http://security.debian.org/',
      release     => 'jessie/updates',
      repos       => 'main contrib non-free';
  }

  #lsb facts require the following
  ensure_resource('package', 'lsb-release', {'ensure' => 'installed' })
}
