#
class debian::ubuntu ($dash = true)
{
  if $::location == 'otp' {
    $mirror_base = 'http://ftp.astral.ro/mirrors'
  } else {
    $mirror_base = "http://${::location}-mirror.wrs.com/mirror"
  }

  $ubuntu_mirror = "${mirror_base}/ubuntu.com/ubuntu"

  include apt

  apt::source {
    'yow-mirror_ubuntu':
      location    => $ubuntu_mirror,
      release     => $::lsbdistcodename,
      repos       => 'main restricted universe multiverse';
    'yow-mirror_ubuntu_security':
      location    => $ubuntu_mirror,
      release     => "${::lsbdistcodename}-security",
      repos       => 'main restricted universe multiverse';
    'yow-mirror_ubuntu_updates':
      location    => $ubuntu_mirror,
      release     => "${::lsbdistcodename}-updates",
      repos       => 'main restricted universe multiverse';
    'yow_puppetlabs_mirror':
      location    => "http://${::location}-mirror.wrs.com/mirror/puppetlabs/apt",
      release     => $::lsbdistcodename,
      repos       => 'main dependencies';
    # Due to git CVE-2016-2315 and CVE-2016-2324 update git on all Ubuntu machines
    'git-core-ppa':
      location     => "http://${::location}-mirror.wrs.com/mirror/apt/ppa.launchpad.net/git-core/ppa/ubuntu/",
      release      => $::lsbdistcodename,
      repos        => 'main',
      architecture => 'amd64',
      include_src  => false,
      key          => 'E1DD270288B4E6030699E45FA1715D88E1DF1F24',
      key_server   => 'keyserver.ubuntu.com';
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

  # No need to waste time trying to optimize boot times with readahead
  ensure_resource('package', 'ureadahead', {'ensure' => 'absent' })
  ensure_resource('package', 'command-not-found', {'ensure' => 'absent' })
}
