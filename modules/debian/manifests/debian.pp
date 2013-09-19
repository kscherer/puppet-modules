#
class debian::debian( $mirror_base ) {

  #koan needs the following packages
  package {
    [ 'yum', 'python-simplejson', 'parted' ]:
      ensure  => installed,
      require => Apt::Source['debian_mirror_stable'];
  }

  #Try to get all debian machines to stable
  class { 'apt::release' : release_id => 'stable' }

  #Sources are managed by puppet only
  class {'apt': purge_sources_list => true }

  apt::source {
    'debian_mirror_stable':
      location    => "${mirror_base}/debian",
      release     => 'stable',
      repos       => 'main contrib non-free',
      include_src => false;
    'yow_apt_mirror':
      ensure      => absent,
      location    => "${mirror_base}/apt",
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
    'yow_puppetlabs_mirror':
      location    => "${mirror_base}/puppetlabs/apt",
      release     => $::lsbdistcodename,
      include_src => false,
      repos       => 'main dependencies';
  }

  apt::source {
    'debian_mirror_testing':
      ensure      => absent,
      location    =>  "${mirror_base}/debian",
      release     => 'testing',
      include_src => false,
      repos       => 'main contrib non-free';
    'debian_mirror_unstable':
      ensure      => absent,
      location    =>  "${mirror_base}/debian",
      release     => 'unstable',
      include_src => false,
      repos       => 'main contrib non-free';
  }

  file {
    #manual script to run on new dell servers
    '/root/partition_drives.sh':
      owner  => 'root', group => 'root', mode => '0700',
      source => 'puppet:///modules/debian/partition_drives.sh';
  }

  #lsb facts require the following
  ensure_resource('package', 'lsb-core', {'ensure' => 'installed' })
}
