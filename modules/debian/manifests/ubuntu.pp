#
class debian::ubuntu (
  $mirror_base,
  $dash = true) {

  $ubuntu_mirror = "${mirror_base}/ubuntu.com/ubuntu"

  #Sources are managed by puppet only
  class {'apt': purge_sources_list => true }

  apt::source {
    'yow-mirror_ubuntu':
      location    => $ubuntu_mirror,
      release     => $::lsbdistcodename,
      repos       => 'main restricted universe multiverse',
      include_src => false;
    'yow-mirror_ubuntu_security':
      location    => $ubuntu_mirror,
      release     => "${::lsbdistcodename}-security",
      repos       => 'main restricted universe multiverse',
      include_src => false;
    'yow-mirror_ubuntu_updates':
      location    => $ubuntu_mirror,
      release     => "${::lsbdistcodename}-updates",
      repos       => 'main restricted universe multiverse',
      include_src => false;
    'yow_puppetlabs_mirror':
      location    => "${mirror_base}/puppetlabs/apt",
      release     => $::lsbdistcodename,
      include_src => false,
      repos       => 'main dependencies';
  }

  if $::lsbmajdistrelease == 12 {
    apt::ppa { 'ppa:kmscherer/collectd': }
  }

  if $dash == true {
    $shell='dash'
  } else {
    $shell='bash'
  }

  #force the default shell to be bash
  exec {
    'bash_setup':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "echo 'dash    dash/sh boolean ${dash}' | debconf-set-selections; dpkg-reconfigure -pcritical dash",
      unless  => "test `readlink /bin/sh` = ${shell}"
  }

  if $::hostname !~ /kscherer/ {
    #add emacs for Jeff but not on Konrad's desktop and server
    ensure_resource('package', 'emacs', {'ensure' => 'installed' })
    ensure_resource('package', 'jove', {'ensure' => 'installed' })
  }

  #Make sure vmware tools are installed on Ubuntu
  if $::virtual == 'vmware' {
    ensure_resource('package', 'open-vm-tools', {'ensure' => 'installed' })
  }
}
