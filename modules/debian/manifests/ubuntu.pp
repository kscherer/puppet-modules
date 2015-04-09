#
class debian::ubuntu (
  $mirror_base = "http://${::location}-mirror.wrs.com/mirror",
  $dash        = true) {

  $ubuntu_mirror = "${mirror_base}/ubuntu.com/ubuntu"

  include apt

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

  if $::lsbmajdistrelease =~ /^12/ {
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

  #Make sure vmware tools are installed on Ubuntu
  if $::virtual == 'vmware' {
    ensure_resource('package', 'open-vm-tools', {'ensure' => 'installed' })
  }

  file_line {
    'stop_loading_all_filesystems':
      path   => '/etc/default/grub',
      line   => 'GRUB_DISABLE_OS_PROBER=true',
      notify => Exec['update-grub'];
    'timeout_grub_menu':
      path   => '/etc/default/grub',
      line   => 'GRUB_RECORDFAIL_TIMEOUT=10',
      notify => Exec['update-grub'];
  }

  exec {
    'update-grub':
      command     => '/usr/sbin/update-grub',
      refreshonly => true;
  }

  # remove obsolete packages every day
  cron {
    'autoremove_packages':
      ensure  => present,
      command => 'PATH=/bin:/sbin:/usr/bin:/usr/sbin /usr/bin/apt-get -y autoremove > /dev/null',
      user    => 'root',
      hour    => '2',
      minute  => fqdn_rand(60, 'autoremove');
  }
}
