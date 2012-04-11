#
class debian::debian {

  #koan needs the following packages
  package {
    [ 'yum', 'python-simplejson', 'parted' ]:
      ensure  => installed,
      require => Apt::Source['debian_mirror_stable'];
  }

  #Due to experiments with 3.x kernel with xen dom0 support, some
  #hosts are debian unstable
  case $::kernelmajversion {
    /^3.*/:  { class { 'apt::release' : release_id => 'unstable' } }
    default: { class { 'apt::release' : release_id => 'stable' } }
  }

  apt::source {
    'debian_mirror_stable':
      location    => "$debian::mirror_base/debian",
      release     => 'stable',
      repos       => 'main contrib non-free',
      include_src => false;
    'yow_apt_mirror':
      location    => "$debian::mirror_base/apt",
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
    'yow_puppetlabs_mirror':
      location    => "$debian::mirror_base/puppetlabs",
      release     => 'squeeze',
      include_src => false,
      repos       => 'main';
  }

  #don't enable testing and unstable on squeeze
  if $::kernelmajversion =~ /^3.*/ {
    apt::source {
    'debian_mirror_testing':
      location    =>  "$debian::mirror_base/debian",
      release     => 'testing',
      include_src => false,
      repos       => 'main contrib non-free';
    'debian_mirror_unstable':
      location    =>  "$debian::mirror_base/debian",
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
