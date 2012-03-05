#
class debian::debian {

  #koan needs the following packages
  package {
    [ 'yum', 'python-simplejson', 'parted' ]:
      ensure => installed;
  }

  #Due to experiments with 3.x kernel with xen dom0 support, some
  #hosts are debian unstable
  case $::kernelmajversion {
    /^3.*/:  { class { 'apt::release' : release_id => 'unstable' } }
    default: { class { 'apt::release' : release_id => 'stable' } }
  }

  apt::source {
    'yow-mirror_squeeze':
      location          => 'http://yow-mirror.ottawa.windriver.com/mirror/debian/',
      release           => 'squeeze',
      repos             => 'main contrib non-free',
      include_src       => false,
      required_packages => 'debian-keyring debian-archive-keyring',
      key               => '55BE302B',
      key_server        => 'subkeys.pgp.net';
    'yow-mirror_testing':
      location    => 'http://yow-mirror.ottawa.windriver.com/mirror/debian/',
      release     => 'testing',
      include_src => false,
      repos       => 'main contrib non-free';
    'yow-mirror_unstable':
      location    => 'http://yow-mirror.ottawa.windriver.com/mirror/debian/',
      release     => 'unstable',
      include_src => false,
      repos       => 'main contrib non-free';
    'yow_apt_mirror':
      location    => 'http://yow-lpgbld-master.ottawa.windriver.com/apt/',
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
    'yow_puppetlabs_mirror':
      location    => 'http://yow-lpgbld-master.ottawa.windriver.com/puppetlabs/',
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
  }

  file {
    #brings testing packages into squeeze
    #TODO consider backports repo
    '01puppet':
      owner  => 'root', group => 'root', mode => '0644',
      path   => '/etc/apt/preferences.d/01puppet',
      source => 'puppet:///modules/debian/01puppet';
    #manual script to run on new dell servers
    '/root/partition_drives.sh':
      owner  => 'root', group => 'root', mode => '0700',
      source => 'puppet:///modules/debian/partition_drives.sh';
  }
}
