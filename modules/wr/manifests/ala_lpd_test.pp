#
class wr::ala_lpd_test {

  include profile::nis
  include git
  include yocto

  include e2croncheck

  motd::register {
    'ala-lpd-test':
      content =>
      'This machine is reserved for Linux Products automated testing only.';
  }

  file {
    '/data':
      ensure => directory;
    ['/data/wr-taf','/data/tm_fast', '/data/fast_build', '/data/fast_prod']:
      ensure  => directory,
      owner   => 'wr-taf',
      group   => 'users',
      mode    => '0755',
      require => Mount['/data'];
    '/etc/security/limits.d/99-wr-taf-nproc.conf':
      ensure  => file,
      content => 'wr-taf soft nproc 5000';
  }

  #packages are needed to run installer
  package {
    [ 'gtk2.i686','libXtst.i686','PackageKit-gtk-module.i686', 'libcanberra-gtk2.i686',
      'gtk2-engines.i686','libXt', 'perl-HTML-TokeParser-Simple' ]:
      ensure => installed;
  }

  #these packages are needed to run FAST
  package {
    [ 'python-configobj', 'python-concurrentloghandler' ]:
      ensure => installed;
  }

  #another developer request
  package {
    ['screen','wiggle']:
      ensure => installed;
  }

  mount {
    '/data':
      ensure   => mounted,
      atboot   => true,
      device   => '/dev/mapper/vg-data',
      fstype   => 'ext4',
      options  => 'defaults',
      remounts => true,
      require  => File['/data'];
  }

  #export /data using nfs
  file {
    '/etc/exports':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "/buildarea *(ro,async,insecure,insecure_locks)\n",
      notify  => Service['nfs'];
  }

  service {
    'nfs':
      ensure => running,
      enable => true;
  }

  if $::hostname == 'ala-lpd-test3' {

    file {
      '/buildarea/dav':
        ensure => directory,
        owner  => 'apache',
        group  => 'apache',
        mode   => '0664';
    }

    include apache
    include apache::mod::dav
  }
}
