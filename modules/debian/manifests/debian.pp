#
class debian::debian( $mirror_base ) {

  #koan needs the following packages
  package {
    [ 'yum', 'python-simplejson', 'parted' ]:
      ensure  => installed,
      require => Apt::Source['debian_mirror_stable'];
  }

  #Due to experiments with 3.x kernel with xen dom0 support, some
  #hosts are debian unstable
  case $::kernelmajversion {
    /^3.*/:  { file { '/etc/apt/apt.conf.d/01release': ensure => absent; } }
    default: { class { 'apt::release' : release_id => 'stable' } }
  }

  #Sources are managed by puppet only
  class {'apt': purge_sources_list => true }

  apt::source {
    'debian_mirror_stable':
      location    => "${mirror_base}/debian",
      release     => 'stable',
      repos       => 'main contrib non-free',
      include_src => false;
    'yow_apt_mirror':
      location    => "${mirror_base}/apt",
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
    'yow_puppetlabs_mirror':
      location    => "${mirror_base}/puppetlabs",
      release     => 'squeeze',
      include_src => false,
      repos       => 'main dependencies';
  }

  #don't enable testing and unstable on squeeze
  if $::kernelmajversion =~ /^3.*/ {
    apt::source {
    'debian_mirror_testing':
      location    =>  "${mirror_base}/debian",
      release     => 'testing',
      include_src => false,
      repos       => 'main contrib non-free';
    'debian_mirror_unstable':
      location    =>  "${mirror_base}/debian",
      release     => 'unstable',
      include_src => false,
      repos       => 'main contrib non-free';
    }
  }

  file {
    #manual script to run on new dell servers
    '/root/partition_drives.sh':
      owner  => 'root', group => 'root', mode => '0700',
      source => 'puppet:///modules/debian/partition_drives.sh';
  }
}
