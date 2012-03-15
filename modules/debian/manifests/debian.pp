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

  $mirror_base = $::hostname ? {
    /^yow.*/ => 'http://yow-mirror.wrs.com/mirror',
    /^pek.*/ => 'http://pek-mirror.wrs.com/',
  }

  apt::source {
    'debian_mirror_stable':
      location          => "$mirror_base/debian",
      release           => 'stable',
      repos             => 'main contrib non-free',
      include_src       => false,
      required_packages => 'debian-keyring debian-archive-keyring',
      key               => '55BE302B',
      key_server        => 'subkeys.pgp.net';
    'yow_apt_mirror':
      location    => 'http://yow-lpgbld-master.wrs.com/apt/',
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
    'yow_puppetlabs_mirror':
      location    => 'http://yow-lpgbld-master.wrs.com/puppetlabs/',
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
  }

  #pek mirror has only debian squeeze
  if $::hostname =~ /^yow.*/ {
    apt::source {
    'debian_mirror_testing':
      location    =>  "$mirror_base/debian",
      release     => 'testing',
      include_src => false,
      repos       => 'main contrib non-free';
    'debian_mirror_unstable':
      location    =>  "$mirror_base/debian",
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
