#
class debian::debian( $mirror_base ) {

  #koan needs the following packages
  package {
    [ 'yum', 'python-simplejson', 'parted' ]:
      ensure  => installed,
      require => Apt::Source['debian_mirror_stable'];
  }

  #base all debian machines on wheezy
  class { 'apt::release' : release_id => 'wheezy' }

  #Sources are managed by puppet only
  class {'apt': purge_sources_list => true }

  apt::source {
    'debian_mirror_wheezy':
      location    => "${mirror_base}/debian",
      release     => 'wheezy',
      repos       => 'main contrib non-free',
      include_src => false;
    'debian_mirror_wheezy_updates':
      location    => "${mirror_base}/debian",
      release     => 'wheezy-updates',
      repos       => 'main contrib non-free',
      include_src => false;
    'debian_mirror_wheezy_security':
      location    => 'http://security.debian.org/',
      release     => 'wheezy/updates',
      repos       => 'main contrib non-free',
      include_src => false;
    'yow_puppetlabs_mirror':
      location    => "${mirror_base}/puppetlabs/apt",
      release     => 'wheezy',
      include_src => false,
      repos       => 'main dependencies';
  }

  apt::source {
    'debian_mirror_jessie':
      ensure      => absent,
      location    =>  "${mirror_base}/debian",
      release     => 'jessie',
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
